From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: rtl8192cu: Fix NULL dereference BUG when using
 new_id
Date: Wed, 06 Feb 2013 10:01:17 +0100
Message-ID: <1360141277.7910.9.camel@jlt4.sipsolutions.net>
References: <1360108823-5141-1-git-send-email-Larry.Finger@lwfinger.net>
	 <1360109904.2857.36.camel@bwh-desktop.uk.solarflarecom.com>
	 <5111A766.70006@lwfinger.net>
	 <1360113382.2857.48.camel@bwh-desktop.uk.solarflarecom.com>
	 (sfid-20130206_021632_180510_96D16282)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1360113382.2857.48.camel-/LGg1Z1CJKReKY3V0RtoKmatzQS1i7+A3tAM5lWOD0I@public.gmane.org> (sfid-20130206_021632_180510_96D16282)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-06 at 01:16 +0000, Ben Hutchings wrote:

> > I don't know why USB differs from PCI, but we do need the dynamic ID here as 
> > there are always new IDs being issued. One of the criteria for adding the ID to 
> > the table is that it works OK with dynamic addition. These devices are 
> > frequently reported by users that do not have the skills to build their own kernel.
> 
> But since there is no way to set the driver_info for a new USB ID
> (again, unlike PCI), your change will reject all dynamic IDs.  (And in
> any case, if the USB core were changed to allow setting driver_info,
> userland would have difficulty providing a valid pointer!)
> 
> It looks like the driver_info is really driver-specific data used to
> share a probe function between multiple drivers.  But you could add
> per-driver probe functions that pass the correct rtl_hal_cfg as an extra
> argument to rtl_usb_probe(), and then dynamic IDs should work.

Some (PCI?) drivers had/have numbers instead of pointers, so userland
can provide a number and it then looks up the pointer in an array.
That's only slightly indirected but makes new_id more useful in that
case.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
