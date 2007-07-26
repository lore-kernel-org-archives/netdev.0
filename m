From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFT] fib_trie: cleanup
Date: Thu, 26 Jul 2007 02:04:31 -0700
Message-ID: <20070726020431.1e693866.akpm@linux-foundation.org>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
	<20070725181557.GF3572@stusta.de>
	<20070726094648.3b7301ae@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Josh Triplett <josh@kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60512 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753664AbXGZJFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 05:05:41 -0400
In-Reply-To: <20070726094648.3b7301ae@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Jul 2007 09:46:48 +0100 Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> Try this out:
>      * replace macro's with inlines
>      * get rid of places doing multiple evaluations of NODE_PARENT

And it fixes the rcu abuse which resulted in
http://lkml.org/lkml/2007/7/25/319.  Which I assume is what inspired the
effort.


your typecasting style is inconsistent:

> +	return rcu_dereference((struct tnode *) (node->parent & ~NODE_TYPE_MASK));

space

> +			   (unsigned long)ptr | NODE_TYPE(node));

no space

> +	while (tn != NULL && (tp = node_parent((struct node *)tn)) != NULL) {

no space

> +		tp = node_parent((struct node *) tn);

space

> +		node_set_parent((struct node *)l, tp);

no space

> +		node_set_parent((struct node *)tn, tp);

no space

> +			struct tnode *parent = node_parent((struct node *) pn);

space

etc.


"no space" seems to be more usual, by about a 50.1:49.9 ratio.  It is
a lot more common in net/:

box:/usr/src/25> grep '[(]unsigned long[)] ' net/*/*.c  | wc -l
91
box:/usr/src/25> grep '[(]unsigned long[)][^ ]' net/*/*.c  | wc -l 
242

