From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [patch] usbnet: fix 100% CPU use on suspended device
Date: Mon, 26 Jul 2010 18:21:14 +0200
Message-ID: <201007261821.15020.oliver@neukum.org>
References: <Pine.LNX.4.44L0.1007261106350.1550-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Elly Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1007261106350.1550-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Montag, 26. Juli 2010, 17:13:23 schrieb Alan Stern:
> On Mon, 26 Jul 2010, Elly Jones wrote:
> 
> > > This isn't right.  The problem should be fixed some other way.  Under
> > > what circumstances are URBs submitted incorrectly?
> > 
> > When the device is autosuspended. What is the proper thing for a
> > device to do here?
> 
> From looking at the code, it appears that the EVENT_DEV_ASLEEP flag
> should be tested in usbnet_bh() the way it is in rx_submit().  But I'm
> not an expert on usbnet; we should ask someone who is, like Oliver.

Sorry, I didn't notice this thread.

The correct way to check for autosuspend in usbnet is to look
at EVENT_DEV_ASLEEP under txq.lock. That being said, usbnet_bh()
uses rx_submit() which does the correct check. The bug seems to be
a lack of error handling in usbnet_bh() regarding the return of rx_submit()

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
