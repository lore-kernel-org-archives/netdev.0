From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Fri, 8 Nov 2013 13:21:20 +0800
Message-ID: <20131108052120.GA15001@gondor.apana.org.au>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:58946 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751356Ab3KHFV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 00:21:27 -0500
Content-Disposition: inline
In-Reply-To: <1383887329.9412.207.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 09:08:49PM -0800, Eric Dumazet wrote:
> On Fri, 2013-11-08 at 12:43 +0800, Herbert Xu wrote:
> 
> > Easy.  You don't physically segment the packet until it's
> > transmitted.  But logically you treat each GRO/GSO packet as if it
> > had already been segmented.
> 
> OK, please submit some patches, because I must be blind.

Honestly it doesn't even matter.  If it's really so bad for your
qdisc, you should just call skb_segment in your qdisc directly.

My point is that even if you did that GRO with your frag_list
patch should still be a win because the stack prior to the qdisc
gets run once instead of two or three times.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
