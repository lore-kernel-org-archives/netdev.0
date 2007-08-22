From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: net/ipv4/fib_trie.c - compile error (Re: 2.6.23-rc3-mm1)
Date: Wed, 22 Aug 2007 10:03:02 -0700
Message-ID: <20070822170302.GC8786@linux.vnet.ibm.com>
References: <20070822020648.5ea3a612.akpm@linux-foundation.org> <46CC5685.7090500@googlemail.com> <20070822154111.GI30705@stusta.de>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel C <nix.or.die@googlemail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:38102 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758858AbXHVRDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 13:03:04 -0400
Content-Disposition: inline
In-Reply-To: <20070822154111.GI30705@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 22, 2007 at 05:41:11PM +0200, Adrian Bunk wrote:
> On Wed, Aug 22, 2007 at 05:30:13PM +0200, Gabriel C wrote:
> > Got it with a randconfig ( http://194.231.229.228/kernel/mm/2.6.23-rc3-mm1/r/randconfig-8 )
> > 
> > ...
> > 
> > net/ipv4/fib_trie.c: In function 'trie_rebalance':
> > net/ipv4/fib_trie.c:969: error: lvalue required as unary '&' operand
> > net/ipv4/fib_trie.c:971: error: lvalue required as unary '&' operand
> > net/ipv4/fib_trie.c:977: error: lvalue required as unary '&' operand
> > net/ipv4/fib_trie.c:980: error: lvalue required as unary '&' operand
> >...
> 
> Side effect of the git-net removal, temporarily removing 
> immunize-rcu_dereference-against-crazy-compiler-writers.patch should 
> work around it.

Alternatively, the following one-line patch to net/ipv4/fib_trie.c could
be used.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 fib_trie.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -urpNa -X dontdiff linux-2.6.23-rc3-mm1/net/ipv4/fib_trie.c linux-2.6.23-rc3-mm1.compile/net/ipv4/fib_trie.c
--- linux-2.6.23-rc3-mm1/net/ipv4/fib_trie.c	2007-08-22 09:20:33.000000000 -0700
+++ linux-2.6.23-rc3-mm1.compile/net/ipv4/fib_trie.c	2007-08-22 09:47:33.000000000 -0700
@@ -94,7 +94,7 @@ typedef unsigned int t_key;
 #define T_LEAF  1
 #define NODE_TYPE_MASK	0x1UL
 #define NODE_PARENT(node) \
-	((struct tnode *)rcu_dereference(((node)->parent & ~NODE_TYPE_MASK)))
+	((struct tnode *)(rcu_dereference((node)->parent) & ~NODE_TYPE_MASK))
 
 #define NODE_TYPE(node) ((node)->parent & NODE_TYPE_MASK)
 
