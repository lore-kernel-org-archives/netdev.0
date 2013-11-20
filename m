From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Wed, 20 Nov 2013 10:39:11 -0800
Message-ID: <20131120183911.GE9611@xanatos>
References: <20131119225822.GA9611@xanatos>
 <Pine.LNX.4.44L0.1311192204140.6891-100000@netrider.rowland.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7437@saturn3.aculab.com>
 <20131120160605.GB9611@xanatos>
 <AE90C24D6B3A694183C094C60CF0A2F6026B743D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B743D-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 20, 2013 at 05:16:12PM -0000, David Laight wrote:
> > Ok, so the networking layer should be fine.  However, with the current
> > patch, if the mass storage driver sends down a scatter-gather list
> > that's bigger than a ring segment, or needs to be split up so it doesn't
> > cross 64K boundaries, then the URB submission will fail.  We don't want
> > that to happen.
> 
> My suspicion is that long SG lists are unusual - otherwise the
> ring expansion code would have been needed much earlier.
> 
> Can anyone remember whether that was needed because of long SG lists
> or because of large numbers of outstanding requests?
>
> I've seen it for network cards - but only because usbnet sends
> down far too many tx buffers.

It was added because USB video and audio drivers queue isochronous URBs
with lots of buffers for each service interval.  So basically, lots of
outstanding requests, not long SG lists was the driving motivation to
add the ring expansion.

Sarah Sharp
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
