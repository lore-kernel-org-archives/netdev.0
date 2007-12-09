From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec replay sequence number overflow behavior? (RFC4303 section 3.3.3)
Date: Sun, 09 Dec 2007 10:13:48 +0800
Message-ID: <E1J1Bfw-0006Kw-00@gondolin.me.apana.org.au>
References: <200712071104.22560.paul.moore@hp.com>
Cc: netdev@vger.kernel.org, latten@us.ibm.com
To: paul.moore@hp.com (Paul Moore)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2384 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751659AbXLICNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 21:13:54 -0500
In-Reply-To: <200712071104.22560.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore <paul.moore@hp.com> wrote:
>
> If it is a bug, I think the basic fix should be pretty simple, changing the 
> above xfrm_output() code to the following:
> 
>   if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
>           XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
> +          if (x->replay.oseq == 0)
> +                  goto error;

Yes we need this check.

However please add an unlikely around it since it's a 1-in-4
billion event :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
