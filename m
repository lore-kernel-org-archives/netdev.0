From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Mon, 4 Nov 2013 00:31:03 +0800
Message-ID: <20131103163103.GA18894@gondor.apana.org.au>
References: <20131029090849.GC5944@cpaasch-mac>
 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.194446.2215574000648693370.davem@davemloft.net>
 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131103122824.GA17394@gondor.apana.org.au>
 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:47138 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752232Ab3KCQbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 11:31:14 -0500
Content-Disposition: inline
In-Reply-To: <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 03, 2013 at 08:28:24AM -0800, Eric Dumazet wrote:
>
> 1) Because we should not call skb_segment() at all on a router ?
> 
> 2) If you aggregate too much on a router, you increase latencies,
>    or if you prefer the RTT of TCP flows.
> 
> 3) Because skb_segment() layer only builds MSS sized skb, so this
>    remove TSO ability on output path
> 
> Splitting a 45 MSS packet into 3 TSO packets (16 + 16 + X MSS) is going
> to be quite complex, given the gso_segment() stuff is meant to segment
> in MSS packets. Adding complexity in this already complex stuff is
> simply not worth it.
> 
> For local TCP, its different, because if you receive such high
> throughput, ability to build full size GRO packet helps to reduce number
> of ACK segments and number of SKB in receive queue (or OFO queue),
> without impacting ACK clocking and TCP dynamics.
> 
> And even if a router does not do this aggregation, the final receiver
> will do.
> 
> So in conclusion, GRO is like TSO : Its not because they are able to use
> 64KB skbs you always _have_ to fill skb to max capacity.

I give up.  It's as if you've ignored everything I've said before.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
