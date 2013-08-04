From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v1 3/4] USBNET: support DMA SG
Date: Sun, 4 Aug 2013 08:19:40 +0800
Message-ID: <CACVXFVPJ0MUaCCDV2ZGdB1_JYXM0iNq=_e7ejjA77dL_TMSigQ@mail.gmail.com>
References: <1375497998-7424-1-git-send-email-ming.lei@canonical.com>
	<1375497998-7424-4-git-send-email-ming.lei@canonical.com>
	<1375509413.2201.2.camel@linux-fkkt.site>
	<20130803.120731.1813304058291781420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: oneukum@suse.de, gregkh@linuxfoundation.org,
	sarah.a.sharp@linux.intel.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, grundler@google.com, freddy@asix.com.tw,
	stern@rowland.harvard.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55586 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab3HDATn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 20:19:43 -0400
In-Reply-To: <20130803.120731.1813304058291781420.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 4, 2013 at 3:07 AM, David Miller <davem@davemloft.net> wrote:
> From: Oliver Neukum <oneukum@suse.de>
> Date: Sat, 03 Aug 2013 07:56:53 +0200
>
>> On Sat, 2013-08-03 at 10:46 +0800, Ming Lei wrote:
>>
>>> @@ -1268,10 +1298,14 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
>>>      entry = (struct skb_data *) skb->cb;
>>>      entry->urb = urb;
>>>      entry->dev = dev;
>>> -    entry->length = length;
>>>
>>>      usb_fill_bulk_urb (urb, dev->udev, dev->out,
>>>                      skb->data, skb->len, tx_complete, skb);
>>> +    if (dev->can_dma_sg) {
>>> +            if (build_dma_sg(skb, urb) < 0)
>>> +                    goto drop;
>>
>> Where do you free urb->sg?
>
> Indeed, this appears to leak.
>
> The devio.c code in the USB layer takes care to manage freeing of
> the urb->sg, so this usbnet code will have to as well.

Hamm, kfree(urb->sg) is removed carelessly in v1, sorry for that.

Will fix it in -v2.

Thanks,
--
Ming Lei
