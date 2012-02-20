From: Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH] net/usbnet: avoid recursive locking in usbnet_stop()
Date: Mon, 20 Feb 2012 17:42:05 +0100
Message-ID: <4F4277DD.3090204@linutronix.de>
References: <20120220160148.GA7910@linutronix.de> <201202201721.38136.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201202201721.38136.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/20/2012 05:21 PM, Oliver Neukum wrote:
>> defer_bh() takes the lok which is hold during unlink_urbs(). The safe
>> walk suggest that the skb will be removed from the list and this is done
>> by defer_bh() so it seems to be okay to drop the lock here.
>
> I am afraid there's something wrong in the hcd driver. Async unlink must
> be possible with a lock held. I cannot approve this patch.

Hmmm. The comment above unlink() says that. Looking through other hcds
it seems that musb is not the only one doing it wrong. Oh well...
>
> 	Regards
> 		Oliver

Sebastian
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
