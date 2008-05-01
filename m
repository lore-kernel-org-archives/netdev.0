From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 01 May 2008 18:42:48 +0800
Message-ID: <E1JrWFU-0001ue-00@gondolin.me.apana.org.au>
References: <20080430214845.GC14219@solarflare.com>
Cc: davem@davemloft.net, kmansley@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com (Ben Hutchings)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44089 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752723AbYEAKm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 06:42:56 -0400
In-Reply-To: <20080430214845.GC14219@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> wrote:
> Large Receive Offload (LRO) destroys packet headers that should be
> preserved when forwarding.  Currently it also triggers a BUG() or WARN()
> in skb_gso_segment().  We should disable it wherever forwarding is
> enabled, and discard LRO skbs with a warning if it is turned back on.

I don't think forwarding GSO packets is bad per se.  However,
doing LRO on forwarded traffic is broken because it breaks the
end-to-end connection.  So I agree that we should detect this
but preferrably not based on the GSO flag as LRO isn't the only
source of GSO traffic and the rest of them can be forwarded just
fine.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
