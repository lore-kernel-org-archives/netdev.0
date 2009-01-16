From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Sat, 17 Jan 2009 10:58:38 +1100
Message-ID: <20090116235837.GA22005@gondor.apana.org.au>
References: <20090115235803.GA9000@gondor.apana.org.au> <49704015.6020503@chelsio.com> <20090116085645.GA14678@gondor.apana.org.au> <49706B87.7080806@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49037 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762248AbZAPX6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 18:58:47 -0500
Content-Disposition: inline
In-Reply-To: <49706B87.7080806@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2009 at 03:12:07AM -0800, Divy Le Ray wrote:
>
> >> without the patch, lro off: 3.8Gbs
> >> without the patch, lro on: 6.1Gbs
> >> with the patch, GRO on: 4.8Gbs.
> > 
> > What about the case of GRO off with the patch? Just checking to
> > make sure that nothing else has changed.
> 
> I'm getting about 3.4Gbs with the patch and GRO off.

I wonder where the 3.8 => 3.4 slow-down is coming from.

> I did some profiling with GRO on and LRO on. Here are typical outputs:
> GRO on:
> CPU 1 :
>       26.445100  copy_user_generic_unrolled          vmlinux
>       10.050300  skb_copy_datagram_iovec             vmlinux
>        5.076900  memcpy                              vmlinux
>        4.636400  process_responses                  cxgb3.ko
>        4.625100  __pskb_pull_tail                    vmlinux
>        4.463300  eth_type_trans                      vmlinux
>        4.420600  inet_gro_receive                    vmlinux
>        4.310500  refill_fl                          cxgb3.ko
>        3.312700  skb_copy_bits                       vmlinux

Thanks, this is very helpful.  The first obvious deficiency
is that napi_fraginfo_skb is causing multiple pskb_may_pull
calls on every fragment which is bad.

I'll get a patch out for you test.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
