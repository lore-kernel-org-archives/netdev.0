From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Thu, 23 Apr 2009 16:00:21 +0800
Message-ID: <20090423080021.GA11712@gondor.apana.org.au>
References: <20090415.030213.249634462.davem@davemloft.net> <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40375 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760647AbZDWIAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 04:00:30 -0400
Content-Disposition: inline
In-Reply-To: <49EE1C32.1060202@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2009 at 03:19:14PM -0400, Andrew Gallatin wrote:
>
> -	if (mgp->csum_flag) {
> -		if ((skb->protocol == htons(ETH_P_IP)) ||
> -		    (skb->protocol == htons(ETH_P_IPV6))) {
> -			skb->csum = csum;
> -			skb->ip_summed = CHECKSUM_COMPLETE;
> -		} else
> -			myri10ge_vlan_ip_csum(skb, csum);
> -	}
> -	netif_receive_skb(skb);
> +	rx_frags[0].page_offset += MXGEFW_PAD;
> +	rx_frags[0].size -= MXGEFW_PAD;
> +	len -= MXGEFW_PAD;
> +	skb_shinfo(skb)->nr_frags = i;
> +	skb->len = len;
> +	skb->data_len = len;
> +	skb->truesize += len;
> +	/*      skb->ip_summed = CHECKSUM_COMPLETE; */

You need to set skb->csum, just as you did for the non-LRO case.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
