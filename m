From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Fix fatal typo in setup of multicast_querier_expired
Date: Mon, 30 Apr 2012 13:27:38 -0400 (EDT)
Message-ID: <20120430.132738.647233864900000159.davem@davemloft.net>
References: <20120430102256.GA32587@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756402Ab2D3R1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:27:44 -0400
In-Reply-To: <20120430102256.GA32587@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Mon, 30 Apr 2012 20:22:56 +1000

> Unfortunately it seems that I didn't properly test the case of
> an expired external querier in the recent multicast bridge series.
> 
> The setup of the timer in that case is completely broken and leads
> to a NULL-pointer dereference.  This patch fixes it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
 ...
> -		    br_multicast_querier_expired, 0);
> +		    br_multicast_querier_expired, (unsigned long)br);
>  	setup_timer(&br->multicast_query_timer, br_multicast_query_expired,
>  		    (unsigned long)br);
>  }
> 
> Sorry for the screw-up.

Please do not put comments after the patch, this made the second hunk
reject when I pulled it out of patchwork.

Anyways, fixed up and applied.
