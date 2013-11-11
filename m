From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Mon, 11 Nov 2013 15:34:53 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1311111525480.17105-100000@netrider.rowland.org>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B73FE@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73FE-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 11 Nov 2013, David Laight wrote:

> > Suppose, for example, the MBP is 1024.  If you have a TD with length
> > 1500, and if it had only one fragment, the last (and only) fragment's
> > length would not less than the MBP and it would not be an exact
> > multiple of the MBP.
> 
> That doesn't matter - eg example 2 in figure 25

You're right.  I do wish the spec had been written more clearly.

> Reading it all again makes me think that a LINK trb is only
> allowed on the burst boundary (which might be 16k bytes).
> The only real way to implement that is to ensure that TD never
> contain LINK TRB.

That's one way to do it.  Or you could allow a Link TRB at an 
intermediate MBP boundary.

It comes down to a question of how often you want the controller to
issue an interrupt.  If a ring segment is 4 KB (one page), then it can
hold 256 TRBs.  With scatter-gather transfers, each SG element
typically refers to something like a 2-page buffer (depends on how
fragmented the memory is).  Therefore a ring segment will describe
somewhere around 512 pages of data, i.e., something like 2 MB.  Since
SuperSpeed is 500 MB/s, you'd end up getting in the vicinity of 250
interrupts every second just because of ring segment crossings.

Using larger ring segments would help.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
