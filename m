From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v3 PATCH 9/9] rhashtable: Add immediate rehash during insertion
Date: Mon, 23 Mar 2015 16:50:33 +0000
Message-ID: <20150323165033.GD20752@casper.infradead.org>
References: <20150323134955.GA16328@gondor.apana.org.au>
 <E1Ya2kO-0004JD-Om@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57112 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883AbbCWQue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 12:50:34 -0400
Content-Disposition: inline
In-Reply-To: <E1Ya2kO-0004JD-Om@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/15 at 12:50am, Herbert Xu wrote:
> @@ -116,6 +117,7 @@ struct rhashtable_params {
>  	unsigned int		max_size;
>  	unsigned int		min_size;
>  	u32			nulls_base;
> +	bool			insecure_elasticity;
>  	size_t			locks_mul;
>  	rht_hashfn_t		hashfn;
>  	rht_obj_hashfn_t	obj_hashfn;

First of all, love the naming of this variable ;-)

> @@ -127,6 +129,7 @@ struct rhashtable_params {
>   * @tbl: Bucket table
>   * @nelems: Number of elements in table
>   * @key_len: Key length for hashfn
> + * @elasticity: Maximum chain length before rehash
>   * @p: Configuration parameters
>   * @run_work: Deferred worker to expand/shrink asynchronously
>   * @mutex: Mutex to protect current/future table swapping

2nd: Seems like you rely on an underflow to allow to "disable"
the elasticity limit. Fair enough, but it would be great to
have the limit configurable as well.

How about making elasticity a signed int, default to 16 if user
specifies 0 and require it to be set to -1 (through a define)
to actually disable the behaviour. That would avoid requiring
two variables to implement this and makes the limit configurable
at the same time.

Otherwise this looks good to me.
