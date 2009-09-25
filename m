From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tunnel: eliminate recursion field
Date: Fri, 25 Sep 2009 14:51:08 -0700
Message-ID: <20090925215108.GA3527@gondor.apana.org.au>
References: <4ABA8254.9000701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54427 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752257AbZIYVvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 17:51:10 -0400
Content-Disposition: inline
In-Reply-To: <4ABA8254.9000701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> It seems recursion field from "struct ip_tunnel" is not anymore needed.
> recursion prevention is done at the upper level (in dev_queue_xmit()),
> since we use HARD_TX_LOCK protection for tunnels.

What if we get async processing in between, e.g., nf_queue?
In that case we could end up with a packet that went round and
around until it exceeded the MTU.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
