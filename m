From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: Set CHECKSUM_UNNECESSARY in tcp_init_nondata_skb
Date: Thu, 8 Apr 2010 19:49:28 +0800
Message-ID: <20100408114928.GA23459@gondor.apana.org.au>
References: <20100408.012617.98660541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:45050 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756025Ab0DHLta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 07:49:30 -0400
Content-Disposition: inline
In-Reply-To: <20100408.012617.98660541.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 01:26:17AM -0700, David Miller wrote:
> 
> Back in commit 04a0551c87363f100b04d28d7a15a632b70e18e7
> ("loopback: Drop obsolete ip_summed setting") we stopped
> setting CHECKSUM_UNNECESSARY in the loopback xmit.
> 
> This is because such a setting was a lie since it implies that the
> checksum field of the packet is properly filled in.
> 
> Instead what happens normally is that CHECKSUM_PARTIAL is set and
> skb->csum is calculated as needed.
> 
> But this was only happening for TCP data packets (via the
> skb->ip_summed assignment done in tcp_sendmsg()).  It doesn't
> happen for non-data packets like ACKs etc.

I don't understand.  If said packet was going across the network,
how could it possibly have worked?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
