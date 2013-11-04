From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Sun, 03 Nov 2013 23:10:41 -0800
Message-ID: <1383549041.4291.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <1383538982.4291.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104042913.GA23021@gondor.apana.org.au>
	 <1383541254.4291.82.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104052321.GA23252@gondor.apana.org.au>
	 <1383545155.4291.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104062202.GA23719@gondor.apana.org.au>
	 <20131104062650.GA23755@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:40904 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946Ab3KDHKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 02:10:42 -0500
Received: by mail-pa0-f47.google.com with SMTP id lf10so6529970pab.6
        for <netdev@vger.kernel.org>; Sun, 03 Nov 2013 23:10:42 -0800 (PST)
In-Reply-To: <20131104062650.GA23755@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-04 at 14:26 +0800, Herbert Xu wrote:

> Also if your scenario had all GRO candidates then not using
> frag_list would seem to be a bad workaround for an underlying
> latency problem.  Rather than arbitrarily limiting the aggregation
> to 22K surely it would make more sense to limit it based on your
> actual latency requirements?

I have never limited GRO aggregation to 22K.

You did this in commit 81705ad1b2f926d
("gro: Do not merge paged packets into frag_list")


I exactly implemented what you suggested in your patch :

"In future we can optimise this further by doing frag_list merging
but making sure that we continue to fill in the page array."

Using frag_list for skb meant to be delivered to local stack is mostly
fine. Its for forwarding that its not a win, since no driver actually
supports frag_list and we revert to skb_segment().

So my latest patch about _not_ building fat skbs with frag_list on a
router makes sense.
