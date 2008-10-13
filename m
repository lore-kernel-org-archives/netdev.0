From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: WARNING (skb_gso_segment) with tg3+bridge in 2.6.27
Date: Mon, 13 Oct 2008 15:59:34 +0800
Message-ID: <20081013075934.GA20244@gondor.apana.org.au>
References: <20081011172002.GA12659@pest> <20081013.004226.171259546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: berni@birkenwald.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43014 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754410AbYJMH7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 03:59:48 -0400
Content-Disposition: inline
In-Reply-To: <20081013.004226.171259546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2008 at 12:42:26AM -0700, David Miller wrote:
> 
> Herbert, is there something about checksum state changing done
> by bridging netfilter that we have to be mindful of in
> skb_gso_segment() and therefore not consider "!= CHECKSUM_PARTIAL"
> a warn-worthy case?

There may well be a bug in bridging netfilter where it destroys
the partial checksum.  However, regardless of what happens there,
it's always a bug to have a non-partial checksum on GSO packets
because the underlying driver may depend on the partial checksum
to be there when computing the checksum for the segmented packets.

I'll take a look at bridging to see if it's doing anything stupid.

Actually I was looking at these skb_gso_segment warning reports
yesterday and I think the problem is more likely to be in the
TCP stack as 90% of the traces I've seen come straight out of
there.

There is a known issue with IPv6 packets where the driver might
turn on TSO6 without IPv6 checksum offload.  However, most of
the traces were IPv4 so there must be something else going on
as well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
