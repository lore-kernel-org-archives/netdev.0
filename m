From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Mon, 4 Nov 2013 12:11:08 +0800
Message-ID: <20131104041108.GA22823@gondor.apana.org.au>
References: <20131029090849.GC5944@cpaasch-mac>
 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.194446.2215574000648693370.davem@davemloft.net>
 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131103122824.GA17394@gondor.apana.org.au>
 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131103163103.GA18894@gondor.apana.org.au>
 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:35186 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751250Ab3KDELT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 23:11:19 -0500
Content-Disposition: inline
In-Reply-To: <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 03, 2013 at 09:26:43AM -0800, Eric Dumazet wrote:
> 
> Not really.
> 
> Have you took a look at the GSO path recently ?
> 
> The days it was handling only IP+TCP are gone.
> 
> If you think you can do better, please do so.

OK maybe I overreacted.

With regards to your point 2), GRO does not introduce any latencies
because it simply relies on NAPI to do the aggregation.  IOW it is
no better or worse latency-wise compared to NAPI.  If you need to
tune it, just use the usual NAPI toggles.

With repsect to point 3), sure we can allow the generation of TSO
segments in skb_segment.

You may be right that this is all too hard, since I haven't actually
sat down and tried to do it yet.

But please give me chance to have a look first before we give up and
install a permanent user-space toggle.

Since this is a crashing bug, I'm OK with adding the linearising
patch to the current tree so that we don't end up shipping with a
known crash in the network stack.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
