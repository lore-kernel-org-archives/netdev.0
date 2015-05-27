From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 200/201] net/ipv4/fib_trie.c:293:3: error:
 implicit declaration of function 'vfree'
Date: Wed, 27 May 2015 00:19:38 -0400 (EDT)
Message-ID: <20150527.001938.461731083662455514.davem@davemloft.net>
References: <201505271204.NKEoVJFK%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, kbuild-all@01.org, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbbE0ETl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 00:19:41 -0400
In-Reply-To: <201505271204.NKEoVJFK%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Wed, 27 May 2015 12:12:08 +0800

> All error/warnings:
> 
>    net/ipv4/fib_trie.c: In function '__node_free_rcu':
>>> net/ipv4/fib_trie.c:293:3: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>       vfree(n);
>       ^
>    net/ipv4/fib_trie.c: In function 'tnode_alloc':
>>> net/ipv4/fib_trie.c:312:3: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
>       return vzalloc(size);
>       ^
>>> net/ipv4/fib_trie.c:312:3: warning: return makes pointer from integer without a cast
>    cc1: some warnings being treated as errors

I'll take care of the fib_trie.c part:

commit ffa915d071ce4a05dcd866409df26513d25786f8
Author: David S. Miller <davem@davemloft.net>
Date:   Wed May 27 00:19:03 2015 -0400

    ipv4: Fix fib_trie.c build, missing linux/vmalloc.h include.
    
    We used to get this indirectly I supposed, but no longer do.
    
    Either way, an explicit include should have been done in the
    first place.
    
       net/ipv4/fib_trie.c: In function '__node_free_rcu':
    >> net/ipv4/fib_trie.c:293:3: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
          vfree(n);
          ^
       net/ipv4/fib_trie.c: In function 'tnode_alloc':
    >> net/ipv4/fib_trie.c:312:3: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
          return vzalloc(size);
          ^
    >> net/ipv4/fib_trie.c:312:3: warning: return makes pointer from integer without a cast
       cc1: some warnings being treated as errors
    
    Reported-by: kbuild test robot <fengguang.wu@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 5a5d9bd..01bce15 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -72,6 +72,7 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/export.h>
+#include <linux/vmalloc.h>
 #include <net/net_namespace.h>
 #include <net/ip.h>
 #include <net/protocol.h>
