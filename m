From: Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH] net/usbnet: avoid recursive locking in usbnet_stop()
Date: Mon, 5 Mar 2012 22:25:00 +0100
Message-ID: <20120305212500.GA8132@linutronix.de>
References: <20120220160148.GA7910@linutronix.de>
 <201202201721.38136.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201202201721.38136.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Oliver Neukum | 2012-02-20 17:21:38 [+0100]:

>Am Montag, 20. Februar 2012, 17:01:48 schrieb Sebastian Andrzej Siewior:
>> |kernel BUG at kernel/rtmutex.c:724!
>> |[<c029599c>] (rt_spin_lock_slowlock+0x108/0x2bc) from [<c01c2330>] (defer_bh+0x1c/0xb4)
>> |[<c01c2330>] (defer_bh+0x1c/0xb4) from [<c01c3afc>] (rx_complete+0x14c/0x194)
>> |[<c01c3afc>] (rx_complete+0x14c/0x194) from [<c01cac88>] (usb_hcd_giveback_urb+0xa0/0xf0)
>> |[<c01cac88>] (usb_hcd_giveback_urb+0xa0/0xf0) from [<c01e1ff4>] (musb_giveback+0x34/0x40)
>> |[<c01e1ff4>] (musb_giveback+0x34/0x40) from [<c01e2b1c>] (musb_advance_schedule+0xb4/0x1c0)
>> |[<c01e2b1c>] (musb_advance_schedule+0xb4/0x1c0) from [<c01e2ca8>] (musb_cleanup_urb.isra.9+0x80/0x8c)
>> |[<c01e2ca8>] (musb_cleanup_urb.isra.9+0x80/0x8c) from [<c01e2ed0>] (musb_urb_dequeue+0xec/0x108)
>> |[<c01e2ed0>] (musb_urb_dequeue+0xec/0x108) from [<c01cbb90>] (unlink1+0xbc/0xcc)
>> |[<c01cbb90>] (unlink1+0xbc/0xcc) from [<c01cc2ec>] (usb_hcd_unlink_urb+0x54/0xa8)
>> |[<c01cc2ec>] (usb_hcd_unlink_urb+0x54/0xa8) from [<c01c2a84>] (unlink_urbs.isra.17+0x2c/0x58)
>> |[<c01c2a84>] (unlink_urbs.isra.17+0x2c/0x58) from [<c01c2b44>] (usbnet_terminate_urbs+0x94/0x10c)
>> |[<c01c2b44>] (usbnet_terminate_urbs+0x94/0x10c) from [<c01c2d68>] (usbnet_stop+0x100/0x15c)
>> |[<c01c2d68>] (usbnet_stop+0x100/0x15c) from [<c020f718>] (__dev_close_many+0x94/0xc8)
>> 
>> defer_bh() takes the lok which is hold during unlink_urbs(). The safe
>> walk suggest that the skb will be removed from the list and this is done
>> by defer_bh() so it seems to be okay to drop the lock here.
>
>I am afraid there's something wrong in the hcd driver. Async unlink must
>be possible with a lock held. I cannot approve this patch.

This argument is no longer valid, the documentation has been updated
[0].
Is it okay for the patch to be merged?

[0] http://git.kernel.org/?p=linux/kernel/git/gregkh/usb.git;a=commitdiff;h=371f3b49f2cb1a8b6ac09b6b108841ca92349eb1;hp=2a5be8783e0016d15e7907ddd212b2c312e196eb

>	Regards
>		Oliver

Sebastian
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
