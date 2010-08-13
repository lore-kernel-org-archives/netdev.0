From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Fri, 13 Aug 2010 06:42:32 -0700 (PDT)
Message-ID: <732137.54230.qm@web180303.mail.gq1.yahoo.com>
References: <201008131258.55016.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthieu CASTET <matthieu.castet-ITF29qwbsa/QT0dZR+AlfA@public.gmane.org>,
	Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Gary King <GKing-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
To: mfuzzey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201008131258.55016.oneukum-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Subject: Re: Problem with non aligned DMA in usbnet on ARM

I remain unconvinced the bug is anywhere except
in whatever host controller is rejecting the
buffers it's given.

Does anyone have proof the bug is elsewhere?


Think for a moment what chaos the kernel would be
if arbitrary subsystems were allowed to introduce
random DMA alignment "requirements".  It would not
be possible to pass buffers between subsystems with
any success at all...

> > 1) Require that usb drivers submit buffers obtained
> from kmalloc() and > friends

Requirements are already documented with the
Description of what memory is DMA-able.  It's
not kmalloc() specifically that's required.

 with no extra offsets.

Offsets have nothing to do with being DMA-able.
They might have to do with working around hardware
flaws though.  (ISTR PXA255 also had a 32-bit goof,
making its DMA engine unusable for most purposes.)

 
> > 2) Require that usb_submit_urb() accept byte aligned buffers.

I believe we already require that.  Of course,
the requirement is on HCDs, not on that call.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
