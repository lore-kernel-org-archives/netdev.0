From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH][RFC] smsc95xx: enable dynamic autosuspend (RFC)
Date: Mon, 10 Dec 2012 13:09:23 +0100
Message-ID: <1404210.ufpq7a3oeI@linux-lqwf.site>
References: <1353607526-19307-6-git-send-email-steve.glendinning@shawell.net> <1355140301-10518-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
To: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1355140301-10518-1-git-send-email-steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 10 December 2012 11:51:41 Steve Glendinning wrote:
> This is a work in-progress patch.  It's not yet complete but
> I thought I'd share it for comments, feedback and testing.
> 
> This patch enables dynamic autosuspend for all devices
> supported by the driver, but it will only actually work on
> LAN9500A (as this has a new SUSPEND3 mode for this purpose).

So this is a problem with remote wakeup on older hardware?

> Unfortunately we don't know if the connected device supports
> this feature until we query its ID register at runtime.
> 
> On unsupported devices (LAN9500/9512/9514) this patch claims
> to support the feature but if enabled it will always return
> failure to the autosuspend call (and fill up the kernel log
> with a message every 2s).
> 
> Suggestions on how best to indicate this capability at runtime
> instead of compile-time would be appreciated, so we don't have
> to repeatedly fail if accidentally enabled.  Or maybe this is
> actually the best way?

If this is a problem with remote wakeup, you should up the
pm counter (usb_autopm_get_noresume()) in .manage_power
That was the reason I implemented this is a callback and not as
a helper in usbnet.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
