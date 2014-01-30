From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Thu, 30 Jan 2014 17:07:11 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1401301702590.31548-100000@netrider.rowland.org>
References: <20140130215523.GC14228@xanatos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Nyman, Mathias" <mathias.nyman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140130215523.GC14228@xanatos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Jan 2014, Sarah Sharp wrote:

> > That's a good plan.  However _some_ restriction will turn out to be
> > necessary.
> > 
> > For example, what will you do if a driver submits an SG list containing
> > 300 elements, each 3 bytes long?  That's too many to fit in a single
> > ring segment, but it's smaller than a TD fragment -- it's even smaller
> > than maxpacket -- so there's no place to split it.  (Not that I think
> > drivers _will_ submit requests like this; this is just to demonstrate
> > the point.)
> > 
> > It ought to be acceptable to require, for example, that an SG URB 
> > contain no more than (say) 100 elements that are smaller than 512 
> > bytes.
> 
> At that point, the xHCI driver or USB core should probably use a bounce
> buffer.  It feels like we should attempt to push down scatter-gather
> lists as far down in the stack as possible, so the upper layers don't
> have to care what alignment, length, or random 64KB boundary splits we
> need.

Okay.  That should be doable, if awkward.

> > ehci-hcd gets along okay with the restriction that each SG element 
> > except the last has to be a multiple of the maxpacket size.  xhci-hcd 
> > can relax this quite a lot, but not all the way.
> 
> What does the EHCI driver do when it receives a SG list from the USB
> networking layer that violates this restriction?

It never receives such lists.  usb_submit_urb() returns -EINVAL before 
the request gets sent to ehci-hcd.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
