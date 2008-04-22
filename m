From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Fix catch-22 with algorithm IDs above 31
Date: Tue, 22 Apr 2008 00:47:27 -0700 (PDT)
Message-ID: <20080422.004727.92629784.davem@davemloft.net>
References: <20080422074304.GA18385@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, latten@us.ibm.com,
	tchicks@us.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59056
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756209AbYDVHrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 03:47:25 -0400
In-Reply-To: <20080422074304.GA18385@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 22 Apr 2008 15:43:04 +0800

> [IPSEC]: Fix catch-22 with algorithm IDs above 31
> 
> As it stands it's impossible to use any authentication algorithms
> with an ID above 31 portably.  It just happens to work on x86 but
> fails miserably on ppc64.
> 
> The reason is that we're using a bit mask to check the algorithm
> ID but the mask is only 32 bits wide.
> 
> After looking at how this is used in the field, I have concluded
> that in the long term we should phase out state matching by IDs
> because this is made superfluous by the reqid feature.  For current
> applications, the best solution IMHO is to allow all algorithms when
> the bit masks are all ~0.
> 
> The following patch does exactly that.
> 
> This bug was identified by IBM when testing on the ppc64 platform
> using the NULL authentication algorithm which has an ID of 251.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, and I'll queue up for -stable, thanks Herbert!

> diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h

Please update your GIT index :-)
