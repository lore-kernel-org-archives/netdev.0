From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 01 May 2008 18:19:54 +0800
Message-ID: <E1JrVtK-0001pb-00@gondolin.me.apana.org.au>
References: <20080430.145820.50450486.davem@davemloft.net>
Cc: bhutchings@solarflare.com, kmansley@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40318 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751009AbYEAKUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 06:20:05 -0400
In-Reply-To: <20080430.145820.50450486.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 30 Apr 2008 22:48:46 +0100
> 
>> Large Receive Offload (LRO) destroys packet headers that should be
>> preserved when forwarding.  Currently it also triggers a BUG() or WARN()
>> in skb_gso_segment().  We should disable it wherever forwarding is
>> enabled, and discard LRO skbs with a warning if it is turned back on.
> 
> Thanks for reposting your work, I'll take a closer look at these
> two patches later today.

This patch completely breaks forwarding of GSO packets in a
virtualised environment where we explicitly want to forward
them as is to reduce per-packet overhead.  So if LRO is causing
problems then I suggest we find a better way around that that
does not penalise all forms of GSO.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
