From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 23 Aug 2017 11:31:05 +1000
Message-ID: <20170823113105.0bd692ea@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Wei Wang <weiwan@google.com>,
        Ido Schimmel <idosch@mellanox.com>,
        iri Pirko <jiri@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/ipv6/ip6_fib.c

between commit:

  c5cff8561d2d ("ipv6: add rcu grace period before freeing fib6_node")

from the net tree and commit:

  a460aa83963b ("ipv6: fib: Add helpers to hold / drop a reference on rt6_info")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/ipv6/ip6_fib.c
index a5ebf86f6be8,549aacc3cb2c..000000000000
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@@ -160,12 -154,7 +161,12 @@@ static void node_free_rcu(struct rcu_he
  	kmem_cache_free(fib6_node_kmem, fn);
  }
  
 +static void node_free(struct fib6_node *fn)
 +{
 +	call_rcu(&fn->rcu, node_free_rcu);
 +}
 +
- static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
+ void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
  {
  	int cpu;
  
