From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Mon, 4 Nov 2013 15:21:55 +0800
Message-ID: <20131104072155.GA24303@gondor.apana.org.au>
References: <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <1383538982.4291.80.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104042913.GA23021@gondor.apana.org.au>
 <1383541254.4291.82.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104052321.GA23252@gondor.apana.org.au>
 <1383545155.4291.89.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104062202.GA23719@gondor.apana.org.au>
 <20131104062650.GA23755@gondor.apana.org.au>
 <1383549041.4291.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:57805 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750873Ab3KDHWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 02:22:05 -0500
Content-Disposition: inline
In-Reply-To: <1383549041.4291.110.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 03, 2013 at 11:10:41PM -0800, Eric Dumazet wrote:
>
> Using frag_list for skb meant to be delivered to local stack is mostly
> fine. Its for forwarding that its not a win, since no driver actually
> supports frag_list and we revert to skb_segment().

Sigh.

Most of the gain these days isn't coming from the hardware anymore,
especially for virtualisation where the network stack is at least
twice as long.  The gain is in paying the cost of the network once
instead of n times for an aggregation of n packets.  So with your
mega-GRO patch, the choice comes down to paying for one trip or
three trips.  The difference may not be trivial, even for a router.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
