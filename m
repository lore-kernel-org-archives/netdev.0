From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] hostap: avoid uninitialized variable use in hfa384x_get_rid
Date: Thu, 28 Jan 2016 22:57:07 +0100
Message-ID: <2640544.07pTZp3kGe@wuerfel>
References: <1453902342-3420391-1-git-send-email-arnd@arndb.de> <20160127192612.GD10826@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Jouni Malinen <j@w1.fi>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160127192612.GD10826-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 27 January 2016 19:26:13 Russell King - ARM Linux wrote:
> On Wed, Jan 27, 2016 at 02:45:26PM +0100, Arnd Bergmann wrote:
> So, why give the compiler a hard time as you're doing, why make the code
> harder to read.  What's wrong with:
> 
>         spin_lock_bh(&local->baplock);
> 
>         res = hfa384x_setup_bap(dev, BAP0, rid, 0);
>         if (res)
>                 goto unlock;
> 
>         res = hfa384x_from_bap(dev, BAP0, &rec, sizeof(rec));
>         if (res)
>                 goto unlock;
> 
>         if (le16_to_cpu(rec.len) == 0) {
>                 /* RID not available */
>                 res = -ENODATA;
>                 goto unlock;
>         }
> 
>         rlen = (le16_to_cpu(rec.len) - 1) * 2;
>         if (exact_len && rlen != len) {
>                 printk(KERN_DEBUG "%s: hfa384x_get_rid - RID len mismatch: rid=0x%04x, len=%d (expected %d)\n",
>                        dev->name, rid, rlen, len);
>                 res = -ENODATA;
>                 goto unlock;
>         }
> 
>         res = hfa384x_from_bap(dev, BAP0, buf, len);
> unlock:
>         spin_unlock_bh(&local->baplock);
> 
> ?
> 

Good idea, I'll send a new version.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
