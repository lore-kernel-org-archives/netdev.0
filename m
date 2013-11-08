From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Fri, 8 Nov 2013 12:43:35 +0800
Message-ID: <20131108044335.GA14787@gondor.apana.org.au>
References: <20131107.161755.355597965034457889.davem@davemloft.net>
 <20131107213111.GA6885@gondor.apana.org.au>
 <20131107.170651.1819930710384730745.davem@davemloft.net>
 <20131108021758.GA13467@gondor.apana.org.au>
 <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
 <1383879113.9412.155.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131108032359.GA14132@gondor.apana.org.au>
 <1383884517.9412.172.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131108042425.GA14577@gondor.apana.org.au>
 <1383885600.9412.187.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:42354 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752683Ab3KHEnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 23:43:41 -0500
Content-Disposition: inline
In-Reply-To: <1383885600.9412.187.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 08:40:00PM -0800, Eric Dumazet wrote:
> On Fri, 2013-11-08 at 12:24 +0800, Herbert Xu wrote:
> 
> > I don't know why you're fixing this problem by disabling/degrading
> > GRO instead of fixing the qdisc to intelligently segment the GRO
> > packet.
> 
> On what criteria you decide that the packet you are going to queue to
> the NIC must be segmented ?

Easy.  You don't physically segment the packet until it's
transmitted.  But logically you treat each GRO/GSO packet as if it
had already been segmented.

> BTW, the Qdisc API doesnt really permit what you describe.
> 
> There are the queue() and dequeue(). Once packet is dequeued, you cannot
> requeue a bunch of packets if you decide to segment the GRO packet.

This logic should be inside the qdisc.  I'm not saying that we
need to implement this for every single qdisc out there, just the
ones that you care about.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
