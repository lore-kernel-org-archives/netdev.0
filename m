From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Wed, 30 Oct 2013 10:05:44 +0800
Message-ID: <20131030020543.GA1925@gondor.apana.org.au>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.194446.2215574000648693370.davem@davemloft.net>
 <1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.220253.1263087684709722001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, christoph.paasch@uclouvain.be,
	netdev@vger.kernel.org, hkchu@google.com, mwdalton@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:34917 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751305Ab3J3CFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 22:05:49 -0400
Content-Disposition: inline
In-Reply-To: <20131029.220253.1263087684709722001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 10:02:53PM -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 29 Oct 2013 17:53:48 -0700
> 
> > So should we apply the first fix to avoid the BUG_ON() ?
> 
> Please be more specific, are you talking about splitting up
> this patch in some way?

I think Eric is referring to the patch that removes the BUG_ON
in skb_segment and deals with the new mega-GRO packets.

I think that's fine for stable, but for the long term we should
fix it properly as these new meag-GRO packets still retain the
existing packet boundaries and are trivially segmentable.

If we are indeed able to do that, I doubt we would even need
the sysctl patch since the GRO performance should be vastly
superior to the non-GRO case, even for a router/bridge.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
