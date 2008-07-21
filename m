From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in	RCU.
Date: Mon, 21 Jul 2008 08:11:20 +0800
Message-ID: <20080721001119.GA6515@gondor.apana.org.au>
References: <E1KKZmE-0000ty-00@gondolin.me.apana.org.au> <1216568119.4847.101.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35406 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754342AbYGUALa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 20:11:30 -0400
Content-Disposition: inline
In-Reply-To: <1216568119.4847.101.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 20, 2008 at 11:35:19AM -0400, jamal wrote:
>
> All actions (on a per-type hash table basis) have an index.
> You create filter rule X and specify action nat.
> You may specify the index of the action when you create the filter X. 
> If you then create another filter rule Y, also using the same action
> index, then that nat action is shared between rule X and rule Y[1].

This is exactly what I want to get rid of because otherwise even
if no index was specified we'll still do a hash insertion which
simply falls apart with a small hash table.  Using a large hash
table on the other is bad for people who only have a few rules.

> [1]This is useful for tow reasons:
> a) memory saving purposes: If you dont care that much about performance
> or on a uniprocessor machine, one action would just be sufficient for
> many rules.
> b) accounting purposes; as you know qdiscs/filters/actions are
> per-device. Over the years, a need has arosen from some users to have a
> "per system" accounting (refer to the IMQ/IFB approach). Eg, if i wanted
> the policer action to account for ingress eth0 and egress eth1 for a
> user, i couldnt do it without some acrobatics.

We could do a dynamic table but so far I'm not convinced that
it's worth anybody's effort to implement :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
