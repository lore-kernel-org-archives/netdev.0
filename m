From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Mon, 23 Mar 2015 11:09:54 +1100
Message-ID: <20150323000954.GB9507@gondor.apana.org.au>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZard-0000wE-Se@gondolin.me.apana.org.au>
 <20150322121755.GH1185@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:33065 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbbCWAKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 20:10:10 -0400
Content-Disposition: inline
In-Reply-To: <20150322121755.GH1185@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 12:17:55PM +0000, Thomas Graf wrote:
> 
> This is misleading. I agree that unconditional shrinking is dangerous.
> Shrinking was an optional feature disabled by default before. The

How was shrinking disabled before? AFAICS it always kicked in at
30%.

> inlining enabled it by default for all users. What is the benefit of
> requiring this logic outside of rhashtable over just adding a flag to
> enable shrinking at 30% utilization?

That would be adding an extra branch on the fast-path for an
operation which almost nobody needs.
 
> >  int rhashtable_shrink(struct rhashtable *ht)
> >  {
> > -	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
> > +	unsigned size = roundup_pow_of_two(atomic_read(&ht->nelems) * 4 / 3);
> 
> If rhashtable_shrink() is called near the 75% border it will cause an
> immediate expansion again. Maybe make this * 3 / 2 so we shrink near
> 30% utilization as before?

Sure that makes sense.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
