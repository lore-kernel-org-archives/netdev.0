From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Mystery packet killing tg3
Date: Tue, 3 May 2005 15:59:11 -0700
Message-ID: <20050503155911.766409c3@dxpl.pdx.osdl.net>
References: <20050502162405.65dfb4a9@localhost.localdomain>
	<20050502200251.38271b61.davem@davemloft.net>
	<20050503140528.1bd2ac74@dxpl.pdx.osdl.net>
	<20050503141314.441c9d75.davem@davemloft.net>
	<1115152907.15156.26.camel@rh4>
	<20050503150333.1ac1c159.davem@davemloft.net>
	<20050503154500.0a53160d@dxpl.pdx.osdl.net>
	<20050503153954.6be62f8a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050503153954.6be62f8a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 May 2005 15:39:54 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Tue, 3 May 2005 15:45:00 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > No, I forced it to always be true and still dies (when taking network down).
> 
> You're reproducing this pretty fast.
> 
> Does the link jam up, or are you just simply downing the interface
> and the stop block messages are printed out?

Initially, it reproduced everytime link came up, we reconfigured the VLAN to
have a mirror port into a laptop to try and capture what was happening, but when
we did that the bootup problem went away. It was in the tg3_reset_hw
during initial dev_open.

Today it only triggers when
I force it by doing something does a dev_close (like ifconfig or rmmod).
Since the message is the same, I assume it is the same or similar problem.

> If it jams up, what kind of traffic are you using to trigger this
> problem?

No traffic is present when the close occurs. But some DMA could be stuck
(forever) in flight at that point.
