From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Thu, 07 Nov 2013 21:40:12 -0800
Message-ID: <1383889212.9412.219.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131107.170651.1819930710384730745.davem@davemloft.net>
	 <20131108021758.GA13467@gondor.apana.org.au>
	 <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383879113.9412.155.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108032359.GA14132@gondor.apana.org.au>
	 <1383884517.9412.172.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108042425.GA14577@gondor.apana.org.au>
	 <1383885600.9412.187.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108044335.GA14787@gondor.apana.org.au>
	 <1383887329.9412.207.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108052120.GA15001@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:58196 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab3KHFkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 00:40:14 -0500
Received: by mail-pb0-f47.google.com with SMTP id rq13so1667955pbb.34
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 21:40:14 -0800 (PST)
In-Reply-To: <20131108052120.GA15001@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 13:21 +0800, Herbert Xu wrote:


> 
> My point is that even if you did that GRO with your frag_list
> patch should still be a win because the stack prior to the qdisc
> gets run once instead of two or three times.
> 

OK, lets me repeat again.

64KB packet receive/aggregation time is more than 540 us on 1Gbps link.

The fact that you split or not the packet at transmit is quite
irrelevant, its already too late.

The problem is not the egress, its GRO if it can aggregate too big
packets.

Most of GRO/GSO benefits are already there with 16 MSS skbs,
we do not gain that much using 44/45 MSS skbs, but increase the
Store-and-Forward Delay by 200 %
