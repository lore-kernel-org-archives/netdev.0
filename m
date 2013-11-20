From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Wed, 20 Nov 2013 11:26:52 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1311201121350.1826-100000@iolanthe.rowland.org>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7438@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7438-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Nov 2013, David Laight wrote:

> > From: Sarah Sharp
> ...
> > (Also, usb-storage aligns the block sizes to 512K, which explains why
> > we've never had an issue with TD fragments with that driver.)
> 
> What is a 'block' in that context?

I think Sarah means that usb-storage requires the block layer to align 
its data buffers to 512-byte boundaries.  (Note: 512 bytes, not 512K.)  
Disk I/O naturally tends to be done in units of the page size, anyway, 
although raw I/O can involve single sectors.

If a user supplies an unaligned buffer, the block layer will set up a 
bounce buffer.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
