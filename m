From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v2 3/4] USBNET: support DMA SG
Date: Mon, 5 Aug 2013 17:23:57 +0800
Message-ID: <CACVXFVOmJvZT51xLhh12S4AtpPaomqv9XQL1NvAOg_uO0PtOrA@mail.gmail.com>
References: <1375692423-9497-1-git-send-email-ming.lei@canonical.com>
	<1375692423-9497-4-git-send-email-ming.lei@canonical.com>
	<1375694068.4676.1.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>,
	Freddy Xin <freddy@asix.com.tw>,
	Alan Stern <stern@rowland.harvard.edu>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35053 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab3HEJYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 05:24:00 -0400
In-Reply-To: <1375694068.4676.1.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 5, 2013 at 5:14 PM, Oliver Neukum <oneukum@suse.de> wrote:
> On Mon, 2013-08-05 at 16:47 +0800, Ming Lei wrote:
>
>> @@ -1268,10 +1298,14 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
>>       entry = (struct skb_data *) skb->cb;
>>       entry->urb = urb;
>>       entry->dev = dev;
>> -     entry->length = length;
>>
>>       usb_fill_bulk_urb (urb, dev->udev, dev->out,
>>                       skb->data, skb->len, tx_complete, skb);
>> +     if (dev->can_dma_sg) {
>> +             if (build_dma_sg(skb, urb) < 0)
>> +                     goto drop;
>
> This is still missing a kfree() for urb->sg in the error case
> of usbnet_start_xmit().

Right, kfree(urb->sg) should be added before usb_free_urb (urb) in
usbnet_start_xmit(), and will fix it in v3.


Thanks,
--
Ming Lei
