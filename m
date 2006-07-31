From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Mon, 31 Jul 2006 17:41:42 +0200
Message-ID: <20060731154142.GK14627@postel.suug.ch>
References: <44CE0BE6.1070108@tcs.hut.fi> <E1G7YKN-0007Ao-00@gondolin.me.apana.org.au> <20060731140214.GA27619@gondor.apana.org.au> <44CE0BE6.1070108@tcs.hut.fi> <E1G7YKN-0007Ao-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ville Nuorvala <vnuorval@tcs.hut.fi>, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:27603 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1030199AbWGaPlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 11:41:21 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060731140214.GA27619@gondor.apana.org.au> <E1G7YKN-0007Ao-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Herbert Xu <herbert@gondor.apana.org.au> 2006-08-01 00:01
> Without a route cache, I think our only choice is to search through
> all tables.  The same thing applies to PMTU updates as well.

I think PMTU etc. should be moved out of the route into a
some form of flow cache. It's currently using rt6_lookup()
which even goes through the rules.

Doing a few thousand trie lookups after Patrick's changes
in the worst case for every redirect might be acceptable
but doing so for every PMTU update could become an issue.

> Actually, if we're adding policy routing, we should seriously consider
> whether living without a routing cache is still viable or not because
> the cost of a route lookup has just gone up.

Absolutely.
