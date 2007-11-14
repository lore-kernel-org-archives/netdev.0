From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/24] [IPSEC]: Separate inner/outer mode processing on
 output
Date: Tue, 13 Nov 2007 21:41:03 -0800 (PST)
Message-ID: <20071113.214103.02140904.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1Ipla3-0001Hs-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45840
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759014AbXKNFlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:41:03 -0500
In-Reply-To: <E1Ipla3-0001Hs-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:31 +0800

> [IPSEC]: Separate inner/outer mode processing on output
> 
> With inter-family transforms the inner mode differs from the outer mode.
> Attempting to handle both sides from the same function means that it
> needs to handle both IPv4 and IPv6 which creates duplication and confusion.
> 
> This patch separates the two parts on the output path so that each function
> deals with one family only.
> 
> In particular, the functions xfrm4_extract_output/xfrm6_extract_output
> moves the pertinent fields from the IPv4/IPv6 IP headers into a neutral
> format stored in skb->cb.  This is then used by the outer mode output
> functions to write the outer IP header.  In this way the output function
> no longer has to know about the inner address family.
> 
> Since the extract functions are only called by tunnel modes (the only
> modes that can support inter-family transforms), I've also moved the
> xfrm*_tunnel_check_size calls into them.  This allows the correct ICMP
> message to be sent as opposed to now where you might call icmp_send with
> an IPv6 packet and vice versa.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
