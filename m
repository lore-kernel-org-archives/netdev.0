From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] net/usbnet: avoid recursive locking in usbnet_stop()
Date: Mon, 20 Feb 2012 17:21:38 +0100
Message-ID: <201202201721.38136.oliver@neukum.org>
References: <20120220160148.GA7910@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:51560 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291Ab2BTQTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 11:19:06 -0500
In-Reply-To: <20120220160148.GA7910@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 20. Februar 2012, 17:01:48 schrieb Sebastian Andrzej Siewior:
> |kernel BUG at kernel/rtmutex.c:724!
> |[<c029599c>] (rt_spin_lock_slowlock+0x108/0x2bc) from [<c01c2330>] (defer_bh+0x1c/0xb4)
> |[<c01c2330>] (defer_bh+0x1c/0xb4) from [<c01c3afc>] (rx_complete+0x14c/0x194)
> |[<c01c3afc>] (rx_complete+0x14c/0x194) from [<c01cac88>] (usb_hcd_giveback_urb+0xa0/0xf0)
> |[<c01cac88>] (usb_hcd_giveback_urb+0xa0/0xf0) from [<c01e1ff4>] (musb_giveback+0x34/0x40)
> |[<c01e1ff4>] (musb_giveback+0x34/0x40) from [<c01e2b1c>] (musb_advance_schedule+0xb4/0x1c0)
> |[<c01e2b1c>] (musb_advance_schedule+0xb4/0x1c0) from [<c01e2ca8>] (musb_cleanup_urb.isra.9+0x80/0x8c)
> |[<c01e2ca8>] (musb_cleanup_urb.isra.9+0x80/0x8c) from [<c01e2ed0>] (musb_urb_dequeue+0xec/0x108)
> |[<c01e2ed0>] (musb_urb_dequeue+0xec/0x108) from [<c01cbb90>] (unlink1+0xbc/0xcc)
> |[<c01cbb90>] (unlink1+0xbc/0xcc) from [<c01cc2ec>] (usb_hcd_unlink_urb+0x54/0xa8)
> |[<c01cc2ec>] (usb_hcd_unlink_urb+0x54/0xa8) from [<c01c2a84>] (unlink_urbs.isra.17+0x2c/0x58)
> |[<c01c2a84>] (unlink_urbs.isra.17+0x2c/0x58) from [<c01c2b44>] (usbnet_terminate_urbs+0x94/0x10c)
> |[<c01c2b44>] (usbnet_terminate_urbs+0x94/0x10c) from [<c01c2d68>] (usbnet_stop+0x100/0x15c)
> |[<c01c2d68>] (usbnet_stop+0x100/0x15c) from [<c020f718>] (__dev_close_many+0x94/0xc8)
> 
> defer_bh() takes the lok which is hold during unlink_urbs(). The safe
> walk suggest that the skb will be removed from the list and this is done
> by defer_bh() so it seems to be okay to drop the lock here.

I am afraid there's something wrong in the hcd driver. Async unlink must
be possible with a lock held. I cannot approve this patch.

	Regards
		Oliver
