From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 04/17] net: bnx2x calls skb_set_rxhash
Date: Fri, 29 Nov 2013 15:43:12 -0500 (EST)
Message-ID: <20131129.154312.1641973884966551317.davem@davemloft.net>
References: <alpine.DEB.2.02.1311260914050.21248@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886Ab3K2UnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 15:43:13 -0500
In-Reply-To: <alpine.DEB.2.02.1311260914050.21248@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 26 Nov 2013 09:22:54 -0800 (PST)

> -		skb->rxhash = tpa_info->rxhash;
> -		skb->l4_rxhash = tpa_info->l4_rxhash;
> +		skb_set_rxhash(skb, tpa_info->rxhash,
> +		    tpa_info->l4_rxhash ? RXHASH_TYPE_L4 : RXHASH_TYPE_L3);
 ...
> -		skb->rxhash = bnx2x_get_rxhash(bp, cqe_fp, &l4_rxhash);
> -		skb->l4_rxhash = l4_rxhash;
> +		rxhash = bnx2x_get_rxhash(bp, cqe_fp, &l4_rxhash);
> +		skb_set_rxhash(skb, rxhash,
> +			       l4_rxhash ? RXHASH_TYPE_L4 : RXHASH_TYPE_L3);

Inconsistent indentation, the second one is correct the first one is
not.

Please audit this in your entire patch set, there are few other
instances.

Thank you.
