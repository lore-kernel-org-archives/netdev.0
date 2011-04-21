From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCHv4] usbnet: Resubmit interrupt URB once if halted
Date: Thu, 21 Apr 2011 17:40:54 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1104211737510.1939-100000@iolanthe.rowland.org>
References: <201104212200.26551.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201104212200.26551.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Apr 2011, Oliver Neukum wrote:

> Am Donnerstag, 21. April 2011, 16:03:34 schrieb Alan Stern:
> > On Tue, 19 Apr 2011, Paul Stewart wrote:
> 
> > > This version of the patch moves the urb submit directly into
> > > usbnet_resume.  Is it okay to submit a GFP_KERNEL urb from
> > > usbnet_resume()?
> 
> Suppose a device of two interfaces one of them storage is autosuspended.
> GFP_KERNEL in the first device to be resumed triggers a pageout to the
> suspended storage device.

True enough, I had forgotten about that.  A resume routine should 
always use GFP_NOIO, not GFP_KERNEL.

In fact this restriction is true in general, not just for USB devices 
containing a mass-storage interface.  The backing device for an evicted 
page might not be resumed until later on in the resume sequence.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
