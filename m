From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][ICMP]: Dst entry leak in icmp_send host re-lookup code
 (v2).
Date: Thu, 03 Apr 2008 13:00:36 -0700 (PDT)
Message-ID: <20080403.130036.135835503.davem@davemloft.net>
References: <20080401121532.GA24470@gondor.apana.org.au>
	<Pine.LNX.4.58.0804021146500.29472@u.domain.uli>
	<20080402124024.GA9547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, ja@ssi.bg, den@openvz.org,
	netdev@vger.kernel.org, devel@openvz.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59832
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758710AbYDCUAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 16:00:36 -0400
In-Reply-To: <20080402124024.GA9547@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 2 Apr 2008 20:40:24 +0800

> [ICMP]: Ensure that ICMP relookup maintains status quo
> 
> The ICMP relookup path is only meant to modify behaviour when
> appropriate IPsec policies are in place and marked as requiring
> relookups.  It is certainly not meant to modify behaviour when
> IPsec policies don't exist at all.
> 
> However, due to an oversight on the error paths existing behaviour
> may in fact change should one of the relookup steps fail.
> 
> This patch corrects this by redirecting all errors on relookup
> failures to the previous code path.  That is, if the initial
> xfrm_lookup let the packet pass, we will stand by that decision
> should the relookup fail due to an error.
> 
> This should be safe from a security point-of-view because compliant
> systems must install a default deny policy so the packet would'nt
> have passed in that case.
> 
> Many thanks to Julian Anastasov for pointing out this error.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
