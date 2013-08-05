From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH v2 3/4] USBNET: support DMA SG
Date: Mon, 05 Aug 2013 11:14:28 +0200
Message-ID: <1375694068.4676.1.camel@linux-fkkt.site>
References: <1375692423-9497-1-git-send-email-ming.lei@canonical.com>
	 <1375692423-9497-4-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>,
	Freddy Xin <freddy@asix.com.tw>,
	Alan Stern <stern@rowland.harvard.edu>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44842 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754730Ab3HEJOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 05:14:33 -0400
In-Reply-To: <1375692423-9497-4-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-05 at 16:47 +0800, Ming Lei wrote:

> @@ -1268,10 +1298,14 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
>  	entry = (struct skb_data *) skb->cb;
>  	entry->urb = urb;
>  	entry->dev = dev;
> -	entry->length = length;
>  
>  	usb_fill_bulk_urb (urb, dev->udev, dev->out,
>  			skb->data, skb->len, tx_complete, skb);
> +	if (dev->can_dma_sg) {
> +		if (build_dma_sg(skb, urb) < 0)
> +			goto drop;

This is still missing a kfree() for urb->sg in the error case
of usbnet_start_xmit().

	Regards
		Oliver
