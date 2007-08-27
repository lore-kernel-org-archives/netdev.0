From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: net/ipv4/fib_trie.c - compile error (Re: 2.6.23-rc3-mm1)
Date: Mon, 27 Aug 2007 08:36:35 +0200
Message-ID: <20070827063635.GB1703@ff.dom.local>
References: <20070822170302.GC8786@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@kernel.org>,
	Gabriel C <nix.or.die@googlemail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752189AbXH0Gfe@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070822170302.GC8786@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22-08-2007 19:03, Paul E. McKenney wrote:
> On Wed, Aug 22, 2007 at 05:41:11PM +0200, Adrian Bunk wrote:
>> On Wed, Aug 22, 2007 at 05:30:13PM +0200, Gabriel C wrote:
>>> Got it with a randconfig ( http://194.231.229.228/kernel/mm/2.6.23-rc3-mm1/r/randconfig-8 )
>>>
>>> ...
>>>
>>> net/ipv4/fib_trie.c: In function 'trie_rebalance':
>>> net/ipv4/fib_trie.c:969: error: lvalue required as unary '&' operand
>>> net/ipv4/fib_trie.c:971: error: lvalue required as unary '&' operand
>>> net/ipv4/fib_trie.c:977: error: lvalue required as unary '&' operand
>>> net/ipv4/fib_trie.c:980: error: lvalue required as unary '&' operand
>>> ...
>> Side effect of the git-net removal, temporarily removing 
>> immunize-rcu_dereference-against-crazy-compiler-writers.patch should 
>> work around it.
> 
> Alternatively, the following one-line patch to net/ipv4/fib_trie.c could
> be used.
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
> 
>  fib_trie.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -urpNa -X dontdiff linux-2.6.23-rc3-mm1/net/ipv4/fib_trie.c linux-2.6.23-rc3-mm1.compile/net/ipv4/fib_trie.c
> --- linux-2.6.23-rc3-mm1/net/ipv4/fib_trie.c	2007-08-22 09:20:33.000000000 -0700
> +++ linux-2.6.23-rc3-mm1.compile/net/ipv4/fib_trie.c	2007-08-22 09:47:33.000000000 -0700
> @@ -94,7 +94,7 @@ typedef unsigned int t_key;
>  #define T_LEAF  1
>  #define NODE_TYPE_MASK	0x1UL
>  #define NODE_PARENT(node) \
> -	((struct tnode *)rcu_dereference(((node)->parent & ~NODE_TYPE_MASK)))
> +	((struct tnode *)(rcu_dereference((node)->parent) & ~NODE_TYPE_MASK))
...

After first reading of this thread I've had an impression it's about
compiler's behavior, but now it seems to me this patch is not an
alternative, but a 'must be' and only proper way of calling
rcu_dereference (with a variable instead of an expression)? Am I
right?

Regards,
Jarek P.
