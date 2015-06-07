From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] fib_trie: Fix potential null pointer dereference
Date: Sun, 7 Jun 2015 08:36:45 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1506070835310.2108@localhost6.localdomain6>
References: <1433590553-4672-1-git-send-email-firogm@gmail.com> <1433592304.1895.73.camel@edumazet-glaptop2.roam.corp.google.com> <20150607060129.GA9265@firo>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Firo Yang <firogm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:59478 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbbFGGgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 02:36:55 -0400
In-Reply-To: <20150607060129.GA9265@firo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, 7 Jun 2015, Firo Yang wrote:

> On Sat, Jun 06, 2015 at 05:05:04AM -0700, Eric Dumazet wrote:
> >On Sat, 2015-06-06 at 19:35 +0800, Firo Yang wrote:
> >> A smatch warning.
> >> When kmem_cache_alloc() failed to alloc memory, a null pointer
> >> will be returned. Redeference null pointer will generate
> >
> >
> >Dereferencing a null pointer will crash.
> >
> >> an unnecessary oops. So, use it after check.
> >> 
> >> Signed-off-by: Firo Yang <firogm@gmail.com>
> >> ---
> >>  net/ipv4/fib_trie.c | 3 ++-
> >>  1 file changed, 2 insertions(+), 1 deletion(-)
> >> 
> >> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> >> index 01bce15..34094c7 100644
> >> --- a/net/ipv4/fib_trie.c
> >> +++ b/net/ipv4/fib_trie.c
> >> @@ -326,12 +326,13 @@ static inline void empty_child_dec(struct key_vector *n)
> >>  static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
> >>  {
> >>  	struct tnode *kv = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
> >> -	struct key_vector *l = kv->kv;
> >> +	struct key_vector *l;
> >>  
> >>  	if (!kv)
> >>  		return NULL;
> >>  
> >>  	/* initialize key vector */
> >> +	l = kv->kv;
> >>  	l->key = key;
> >>  	l->pos = 0;
> >>  	l->bits = 0;
> >
> >Fixes: dc35dbeda3e0 ("fib_trie: Add tnode struct as a container for fields not needed in key_vector")
> >Acked-by: Eric Dumazet <edumazet@google.com>
> >
> >Thanks.
> 
> Hi Eric,
> Please discard this useless patch figured out by Alexander Duyck. 
> I will send a patch to Smatch for eliminating the negative warning.

I think that many people would make the same mistake when looking at the 
code.  The change doesn't seem to hurt anything?

julia
