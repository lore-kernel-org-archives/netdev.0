From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Sat, 16 Nov 2013 01:38:24 +0000
Message-ID: <1384565904.29151.66.camel@bwh-desktop.uk.level5networks.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B740B@saturn3.aculab.com>
	 <Pine.LNX.4.44L0.1311131113090.1424-100000@iolanthe.rowland.org>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B741A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B741A-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-11-13 at 16:58 +0000, David Laight wrote:
[...]
> > > > > You can split a bulk TD on a 1k boundary and the target won't know the
> > > > > difference.
> > > >
> > > > The target won't know the difference, but the host will.  Here's an
> > > > example: Suppose the driver submits two URBs, each for a data-in
> > > > transfer of 32 KB.  You split each URB up into two 16-KB TDs; let's
> > > > call them A, B, C, and D (where A and B make up the first URB, and C
> > > > and D make up the second URB).
> > >
> > > I was thinking about OUT transfers, IN ones are unlikely to be badly
> > > fragmented.
> > 
> > Maybe not for the network stack, but OUT and IN end up equally
> > fragmented for the storage stack.
> 
> But the minimum fragment size is (probably) 4k.
> For the network stack an OUT transfer might have a lot (and I mean lots)
> of fragments (there may be constraints, and linearising the skb is a option).
[...]

The maximum number of fragments in the skb is going to be 17 (including
the 'head' area).  (I'm ignoring NETIF_F_FRAGLIST which is not normally
supported by physical device drivers.)

I don't know how many fragments that can end up as, at the USB level.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
