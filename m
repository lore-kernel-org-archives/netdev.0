From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v1 3/4] USBNET: support DMA SG
Date: Sat, 03 Aug 2013 12:07:31 -0700 (PDT)
Message-ID: <20130803.120731.1813304058291781420.davem@davemloft.net>
References: <1375497998-7424-1-git-send-email-ming.lei@canonical.com>
	<1375497998-7424-4-git-send-email-ming.lei@canonical.com>
	<1375509413.2201.2.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org,
	stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org
To: oneukum-l3A5Bk7waGM@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375509413.2201.2.camel-B2T3B9s34ElbnMAlSieJcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Date: Sat, 03 Aug 2013 07:56:53 +0200

> On Sat, 2013-08-03 at 10:46 +0800, Ming Lei wrote:
> 
>> @@ -1268,10 +1298,14 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
>>  	entry = (struct skb_data *) skb->cb;
>>  	entry->urb = urb;
>>  	entry->dev = dev;
>> -	entry->length = length;
>>  
>>  	usb_fill_bulk_urb (urb, dev->udev, dev->out,
>>  			skb->data, skb->len, tx_complete, skb);
>> +	if (dev->can_dma_sg) {
>> +		if (build_dma_sg(skb, urb) < 0)
>> +			goto drop;
> 
> Where do you free urb->sg?

Indeed, this appears to leak.

The devio.c code in the USB layer takes care to manage freeing of
the urb->sg, so this usbnet code will have to as well.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
