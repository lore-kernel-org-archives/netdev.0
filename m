From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: 31 Mar 2005 16:25:25 -0500
Message-ID: <1112304324.1074.82.camel@jzny.localdomain>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
	 <20050331120410.7effa94d@dxpl.pdx.osdl.net>
	 <1112303431.1073.67.camel@jzny.localdomain>
	 <20050331131707.69f451ea@dxpl.pdx.osdl.net>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050331131707.69f451ea@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-31 at 16:17, Stephen Hemminger wrote:

> Any real hardware only has a single receive packet source (the interrupt routine),
> and the only collision would be in the case of interrupt migration.  So having
> per-device-per-CPU queue's would be overkill and more complex because
> the NAPI scheduling is per-netdevice rather than per-queue (though that
> could be fixed).

The idea behind the current per-CPU queues is to avoid cache
ping-ponging; same queue shared across multiple CPUs with roundrobin
interupts will get expensive. In other words these non-NAPI devices will
be migrating across CPUs based on interupts a lot more under heavy
traffic.
In the case of NAPI, the issue doesnt exist: A device stays on the same
queue until all packets are offloaded of it. Depending on CPU capacity
it could stay forever on the same CPU.

So my suggestion to do per CPU queues for these devices is avoid that.

> > I think performance will be impacted in all devices. imo, whatever needs
> > to go in needs to have some experimental data to back it
> 
> Experiment with what? Proving an absolute negative is impossible.
> I will test loopback and non-NAPI version of a couple of gigabit drivers
> to see. 

I think that will do. I dont know how heavy traffic you can pound.
Collecting and comparing some profiles between the two schems will help.

cheers,
jamal
