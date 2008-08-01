From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Fri, 1 Aug 2008 17:25:48 +0800
Message-ID: <20080801092548.GA18424@gondor.apana.org.au>
References: <48929C5B.5030108@cn.fujitsu.com> <E1KOqf7-0004lB-00@gondolin.me.apana.org.au> <20080801.021825.51896743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53305 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750834AbYHAJZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 05:25:54 -0400
Content-Disposition: inline
In-Reply-To: <20080801.021825.51896743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 01, 2008 at 02:18:25AM -0700, David Miller wrote:
>
> SCTP calls ip_queue_xmit() and ip6_xmit() directly with it's ipfragok
> argument, so it is used for these functions.
> 
> As a result ->icsk_af_ops->queue_xmit() needs to have arguments
> at least matching those function's prototypes.

Hmm, so SCTP is the only reason why ipfragok exists and yet it
doesn't even use icsk_af_ops->queue_xmit.  So unless SCTP has
plans to use icsk_af_ops, perhaps we could provide it a copy of
ip_queue_xmit/ip6_xmit that has the ipfragok argument and then
put a wrapper around them without the argument for icsk_af_ops
and everybody else.

Who knows, it might even save more memory than the ethtool hack :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
