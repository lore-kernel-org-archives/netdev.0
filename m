From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bgmac: add support for Byte Queue Limits
Date: Sat, 28 Sep 2013 15:18:49 -0700
Message-ID: <1380406729.3596.7.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380403393-12113-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, zajec5@gmail.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:39630 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755152Ab3I1WSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 18:18:50 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so4043889pdi.33
        for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 15:18:50 -0700 (PDT)
In-Reply-To: <1380403393-12113-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-09-28 at 23:23 +0200, Hauke Mehrtens wrote:
> This makes it possible to use some more advanced queuing
> techniques with this driver.

> @@ -1198,6 +1206,8 @@ static netdev_tx_t bgmac_start_xmit(struct sk_buff *skb,
>  	struct bgmac *bgmac = netdev_priv(net_dev);
>  	struct bgmac_dma_ring *ring;
>  
> +	netdev_sent_queue(net_dev, skb->len);
> +
>  	/* No QOS support yet */
>  	ring = &bgmac->tx_ring[0];
>  	return bgmac_dma_tx_add(bgmac, ring, skb);


Well, no.

You must call netdev_sent_queue() only if packet is really queued.
