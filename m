From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: Thu, 31 Mar 2005 13:17:07 -0800
Message-ID: <20050331131707.69f451ea@dxpl.pdx.osdl.net>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
	<20050331120410.7effa94d@dxpl.pdx.osdl.net>
	<1112303431.1073.67.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@znyx.com
In-Reply-To: <1112303431.1073.67.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 31 Mar 2005 16:10:32 -0500
Jamal Hadi Salim <hadi@znyx.com> wrote:

> On Thu, 2005-03-31 at 15:04, Stephen Hemminger wrote:
> > Here is another alternative that seems better than the earlier posting. It uses
> > a per device receive queue for non-NAPI devices.  The only issue is that then
> > we lose the per-cpu queue's and that could impact the loopback device performance.
> > If that is really an issue, then the per-cpu magic should be moved to the loopback
> > device.
> > 
> 
> The repurcassions of going from per-CPU-for-all-devices queue
> (introduced by softnet) to per-device-for-all-CPUs maybe huge in my
> opinion especially in SMP. A closer view of whats there now maybe
> per-device-per-CPU backlog queue.

Any real hardware only has a single receive packet source (the interrupt routine),
and the only collision would be in the case of interrupt migration.  So having
per-device-per-CPU queue's would be overkill and more complex because
the NAPI scheduling is per-netdevice rather than per-queue (though that
could be fixed).

> I think performance will be impacted in all devices. imo, whatever needs
> to go in needs to have some experimental data to back it

Experiment with what? Proving an absolute negative is impossible.
I will test loopback and non-NAPI version of a couple of gigabit drivers
to see. 
