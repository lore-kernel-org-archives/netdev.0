From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 02/15] net: bnx2x calls skb_set_hash
Date: Wed, 18 Dec 2013 11:00:29 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B74A3@saturn3.aculab.com>
References: <alpine.DEB.2.02.1312172316370.24389@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "Tom Herbert" <therbert@google.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59650 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750855Ab3LRLB7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 06:01:59 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01240-07 for <netdev@vger.kernel.org>;
 Wed, 18 Dec 2013 11:01:55 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <alpine.DEB.2.02.1312172316370.24389@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Tom Herbert
> Drivers should call skb_set_hash to set the hash and its type
> in an skbuff.
...
>  		/* Set Toeplitz hash for a none-LRO skb */
> -		skb->rxhash = bnx2x_get_rxhash(bp, cqe_fp, &l4_rxhash);
> -		skb->l4_rxhash = l4_rxhash;
> +		rxhash = bnx2x_get_rxhash(bp, cqe_fp, &l4_rxhash);
> +		skb_set_hash(skb, rxhash,
> +			     l4_rxhash ? PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);

This is all silly, skb_set_rxhash() just undoes that conditional.
The compiler might be smart enough to undo it all.

IMHO skb->l4_rxhash should be skb->rx_hash_type and set to one
of the PKT_HASH_TYPE_xxx constants.
(with 0 => no hash assigned)

	David
