From: Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH] net/usbnet: avoid recursive locking in usbnet_stop()
Date: Mon, 20 Feb 2012 22:02:28 +0100
Message-ID: <4F42B4E4.5090100@linutronix.de>
References: <Pine.LNX.4.44L0.1202201524290.11040-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1202201524290.11040-100000-pYrvlCTfrz9XsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/20/2012 09:31 PM, Alan Stern wrote:
> On Mon, 20 Feb 2012, Sebastian Andrzej Siewior wrote:
>
>> On 02/20/2012 05:21 PM, Oliver Neukum wrote:
>>>> defer_bh() takes the lok which is hold during unlink_urbs(). The safe
>>>> walk suggest that the skb will be removed from the list and this is done
>>>> by defer_bh() so it seems to be okay to drop the lock here.
>>>
>>> I am afraid there's something wrong in the hcd driver. Async unlink must
>>> be possible with a lock held. I cannot approve this patch.
>>
>> Hmmm. The comment above unlink() says that. Looking through other hcds
>> it seems that musb is not the only one doing it wrong. Oh well...
>
> What's the issue here?
>
> If a driver calls usb_unlink_urb() while holding a lock, and the
> completion routine tries to acquire the same lock, then deadlock is
> possible.  The fact that usb_unlink_urb() is asynchronous is not a
> guarantee of anything; the HCD is allowed to call the completion
> handler from within usb_unlink_urb().
>
> It's true that the kerneldoc for usb_unlink_urb() says "This request is
> always asynchronous".  It might be a good idea to remove the word
> "always", because it seems to give people the wrong idea.

I see. So you approve that patch and suggest to remove the "always"
wording plus adding something like "the hcd might call complete routine
during unlink" ?

>
> Alan Stern
>

Sebastian
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
