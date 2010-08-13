From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Fri, 13 Aug 2010 12:58:54 +0200
Message-ID: <201008131258.55016.oneukum@suse.de>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com> <4C642AA9.1060404@parrot.com> <4C65193E.4090807@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Matthieu CASTET <matthieu.castet-ITF29qwbsa/QT0dZR+AlfA@public.gmane.org>,
	"Russell King - ARM Linux" <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Gary King <GKing-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-usb" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
To: mfuzzey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C65193E.4090807-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Freitag, 13. August 2010, 12:06:54 schrieb Martin Fuzzey:

> So I think a policy needs to be defined to ensure this and enforced in
> the code. I can see two possible methods:
> 
> 1) Require that usb drivers submit buffers obtained from kmalloc() and
> friends with no extra offsets. If they want some other alignment later
> they can use memmove in the completion handler. Enforce this in the core
> by checking the buffer pointers are aligned to ARCH_KMALLOC_MINALIGN
> 
> or
> 
> 2) Require that usb_submit_urb() accept byte aligned buffers. Enforce
> this by a new test in usbtest (which all HCDs are expected to pass).
> Implement it either in individual HCDs that require it or by letting
> HCDs inform the core of their requirements and have the core do the
> alignment (as it already does the dma mapping). Of course HCDs that can
> implement byte aligned transfers (either natively or using tricks such
> as the one Russell suggested) should do so.
> 
> I think 2) is the better solution because:
> a) Solution 1 will impose a runtime overhead even on platforms / HCDs
> that don't need it (including the most common cases)
> b) There are more drivers than HCDs

Yes. But it doesn't prevent you from publishing this information so
drivers can help the lower levels.
	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
