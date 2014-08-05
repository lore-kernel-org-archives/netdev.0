From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 4/4 RFC] pktgen: Allow sending IPv4 TCP
 packets
Date: Tue, 05 Aug 2014 13:09:01 -0700 (PDT)
Message-ID: <20140805.130901.2116578415179622318.davem@davemloft.net>
References: <1407159435-7951-1-git-send-email-zoltan.kiss@citrix.com>
	<1407159435-7951-5-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, minipli@googlemail.com,
	dborkman@redhat.com, tgraf@suug.ch, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753922AbaHEUJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 16:09:02 -0400
In-Reply-To: <1407159435-7951-5-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Mon, 4 Aug 2014 14:37:14 +0100

> @@ -3559,6 +3616,14 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>  		pkt_dev->last_pkt_size = pkt_dev->skb->len;
>  		pkt_dev->allocated_skbs++;
>  		pkt_dev->clone_count = 0;	/* reset counter */
> +
> +		if (netif_needs_gso(pkt_dev->skb, netif_skb_features(pkt_dev->skb))) {
> +			pr_err("Device don't have necessary GSO features! netif_skb_features: %llX summed %u\n",
> +			       netif_skb_features(pkt_dev->skb),
> +			       pkt_dev->skb->ip_summed);
> +			pkt_dev->sofar++;
> +			goto out;
> +		}
>  	}
>  
>  	if (pkt_dev->delay && pkt_dev->last_ok)

Woe be to the person who actually triggers this condition.  This function
happens potentially millions of times per second, there is no value in
emitting a log message every time.
