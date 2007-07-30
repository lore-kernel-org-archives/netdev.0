From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] fib_trie: whitespace cleanup
Date: Mon, 30 Jul 2007 10:07:34 -0700
Message-ID: <20070730170734.GB11257@linux.vnet.ibm.com>
References: <20070725040304.111550f4.akpm@linux-foundation.org> <20070725181557.GF3572@stusta.de> <20070726094648.3b7301ae@oldman> <20070726020431.1e693866.akpm@linux-foundation.org> <20070726114942.5615ed7b@oldman.hamilton.local> <20070726154421.GB24650@linux.vnet.ibm.com> <20070726215630.96f971d4.akpm@linux-foundation.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Adrian Bunk <bunk@stusta.de>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Ingo Molnar <mingo@elte.hu>, Josh Triplett <josh@kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:34568 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965059AbXG3RHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 13:07:37 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6UH7aGV003340
	for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 13:07:36 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6UH7aEg532928
	for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 13:07:36 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6UH7Zbg000707
	for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 13:07:36 -0400
Content-Disposition: inline
In-Reply-To: <20070726215630.96f971d4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 26, 2007 at 09:56:30PM -0700, Andrew Morton wrote:
> On Thu, 26 Jul 2007 08:44:21 -0700 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Thu, Jul 26, 2007 at 11:49:42AM +0100, Stephen Hemminger wrote:
> > > Whitespace cleanup run code through lindent then cleanup results.
> > > Applys after other two patches.
> > > 
> > > --- a/net/ipv4/fib_trie.c	2007-07-26 10:17:21.000000000 +0100
> > > +++ b/net/ipv4/fib_trie.c	2007-07-26 11:47:52.000000000 +0100
> > > @@ -156,7 +156,8 @@ struct trie {
> > >  };
> > > 
> > >  static void put_child(struct trie *t, struct tnode *tn, int i, struct node *n);
> > > -static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n, int wasfull);
> > > +static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n,
> > > +				  int wasfull);
> > >  static struct node *resize(struct trie *t, struct tnode *tn);
> > >  static struct tnode *inflate(struct trie *t, struct tnode *tn);
> > >  static struct tnode *halve(struct trie *t, struct tnode *tn);
> > > @@ -167,13 +168,12 @@ static struct trie *trie_local = NULL, *
> > > 
> > >  static inline struct tnode *node_parent(struct node *node)
> > >  {
> > > -	return rcu_dereference((struct tnode *) (node->parent & ~NODE_TYPE_MASK));
> > > +	return rcu_dereference((struct tnode *)(node->parent & ~NODE_TYPE_MASK));
> > 
> > The potential issue is applying rcu_dereference() to an rvalue
> > as opposed to an lvalue.  So how about the following?
> > 
> 
> I did this:
> 
> static inline struct tnode *node_parent(struct node *node)
> {
> 	struct tnode *ret;
> 
> 	ret = (struct tnode *)(node->parent & ~NODE_TYPE_MASK);
> 	return rcu_dereference(ret);
> }

I would feel more comfortable with the rcu_dereference() covering the
initial fetch from node->parent, but do not have any hard objections
to your approach.

						Thanx, Paul
