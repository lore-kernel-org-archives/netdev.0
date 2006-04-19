From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip_route_input panic fix
Date: Wed, 19 Apr 2006 10:17:21 +1000
Message-ID: <20060419001721.GA12233@gondor.apana.org.au>
References: <20060417171253.4e988afc@localhost.localdomain> <E1FVk6q-0000Tf-00@gondolin.me.apana.org.au> <20060418235222.GA20504@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33295 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750702AbWDSARe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 20:17:34 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060418235222.GA20504@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 19, 2006 at 03:52:22AM +0400, Alexey Kuznetsov wrote:
> 
> Actually, this weird case in inet_get_route() is the only place, where

There is also the ARP code which passes an ARP packet through that
would get dereferenced as an IP packet.  Granted this shouldn't crash
because nh is set properly.

But we really should make up our mind as to whether the routing key
comes from the arguments to ip_route_input (src/dst/...) or the skb.

Using both is just asking for trouble.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
