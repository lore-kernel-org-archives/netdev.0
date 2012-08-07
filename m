From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: fib: fix incorrect call_rcu_bh()
Date: Tue, 7 Aug 2012 09:34:54 -0700
Message-ID: <20120807163454.GF2378@linux.vnet.ibm.com>
References: <1344336431.28967.14.camel@edumazet-glaptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:35913 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754725Ab2HGQwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 12:52:18 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 7 Aug 2012 12:52:07 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 2BA056E9161
	for <netdev@vger.kernel.org>; Tue,  7 Aug 2012 12:34:58 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q77GYuGq056026
	for <netdev@vger.kernel.org>; Tue, 7 Aug 2012 12:34:56 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q77GYtO1030908
	for <netdev@vger.kernel.org>; Tue, 7 Aug 2012 10:34:55 -0600
Content-Disposition: inline
In-Reply-To: <1344336431.28967.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 07, 2012 at 12:47:11PM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> After IP route cache removal, I believe rcu_bh() has very little use and
> we should remove this RCU variant, since it adds some cycles in fast
> path.

Do you mean remove all uses of RCU-bh globally and also removing the
implementation itself?  That would actually be a good thing, from my
perspective.

Or were you meaning something more localized?

							Thanx, Paul

> Anyway, the call_rcu_bh() use in fib_true is obviously wrong, since
> some users only assert rcu_read_lock().
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> ---
>  net/ipv4/fib_trie.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index f0cdb30..57bd978 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -367,7 +367,7 @@ static void __leaf_free_rcu(struct rcu_head *head)
> 
>  static inline void free_leaf(struct leaf *l)
>  {
> -	call_rcu_bh(&l->rcu, __leaf_free_rcu);
> +	call_rcu(&l->rcu, __leaf_free_rcu);
>  }
> 
>  static inline void free_leaf_info(struct leaf_info *leaf)
> 
> 
