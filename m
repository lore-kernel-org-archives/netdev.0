From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: Help testing for USB ethernet/xHCI regression
Date: Thu, 30 Jan 2014 10:44:12 -0800
Message-ID: <20140130184412.GA3787@xanatos>
References: <22081260.RNay0J72dY@athas>
 <20140129215408.GC5991@xanatos>
 <063D6719AE5E284EB5DD2968C1650D6D0F6ACF20@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "renevant-CkBdp7X+a1oIQCUVoCVjmQ@public.gmane.org" <renevant-CkBdp7X+a1oIQCUVoCVjmQ@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6ACF20-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 30, 2014 at 09:44:53AM +0000, David Laight wrote:
> From: Sarah Sharp
> > > Current issue is when plugging in the ax88179 there is lag when bringing the
> > > interface up and a bunch of kernel messages:

> > > [   79.481028] IPv6: ADDRCONF(NETDEV_UP): enp7s0u1: link is not ready
> > > [   82.210721] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> > > [   82.338947] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> > > [   82.467148] ax88179_178a 2-1:1.0 enp7s0u1: kevent 4 may have been dropped
> > > [   82.470028] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> > > [   82.595364] ax88179_178a 2-1:1.0 enp7s0u1: kevent 4 may have been dropped
> > > [   82.598312] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> > > [   82.723580] ax88179_178a 2-1:1.0 enp7s0u1: kevent 4 may have been dropped
> > > [   82.726487] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> > > [   82.851796] ax88179_178a 2-1:1.0 enp7s0u1: kevent 4 may have been dropped
> > > [   82.854642] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1

> > 
> > With which kernel?
> 
> I saw similar issues testing some patches yesterday.
> Both with the ax179_178a and smsx95xx cards (connected to xhci).
> My kernel claims to be 3.13.0-dsl+ but it is lying since it was
> updated from linus's tree earlier this week.
> I'd not seen any similar delays until the last week or so.

I see a report that these types of errors have been seen since the 3.11
kernel:

http://marc.info/?l=linux-usb&m=139105963723745&w=2

Since the USB ethernet scatter-gather support wasn't added until the
3.12 kernel, it's unlikely that the xHCI TD fragment issue is actually
the root cause.

The interesting piece of information in that report is that when the USB
3.0 device falls back to USB 2.0 speeds under xHCI, it works.

> The xhci controller I'm using is the Intel 'Panther Point' 8086:1e31
> rev 4 (also says 8086:1e2d and 8086:1e26).

That's the host I have as well.  I've been able to find an ASIX device
with the right chipset, so I'm going to poke around at what's happening
at the USB 3.0 bus level.

Sarah Sharp
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
