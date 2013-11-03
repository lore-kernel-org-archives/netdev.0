From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Sun, 3 Nov 2013 20:28:24 +0800
Message-ID: <20131103122824.GA17394@gondor.apana.org.au>
References: <20131029090849.GC5944@cpaasch-mac>
 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.194446.2215574000648693370.davem@davemloft.net>
 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:51614 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753238Ab3KCM2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 07:28:45 -0500
Content-Disposition: inline
In-Reply-To: <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 02, 2013 at 07:01:37AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
> by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> 
> skb_segment() only deals with a frag_list chain containing MSS sized
> fragments. Even if we fix this problem, its better if GRO layer
> doesn't build skb with a frag_list in the first place, to let TSO
> packets reaching output devices.
>  
> David Miller and Ben Hutchings suggested we keep track of number of
> forwarding users to be able to :
> 
> - Disable LRO
> - Make sure GRO layer do not use skb frag_list to extend skb capacity

Why are we still doing this instead of fixing skb_segment to
deal with skb frag_list properly?

LRO is legacy code and we should not be adding similar cruft
to GRO.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
