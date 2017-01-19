From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the rcu tree
Date: Thu, 19 Jan 2017 14:34:45 +1100
Message-ID: <20170119143445.6b65dc8b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ursula Braun <ubraun@linux.vnet.ibm.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:39553 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751976AbdASDpN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 22:45:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,

After merging the rcu tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

net/smc/af_smc.c:102:16: error: 'SLAB_DESTROY_BY_RCU' undeclared here (not in a function)
  .slab_flags = SLAB_DESTROY_BY_RCU,
                ^

Caused by commit

  c7a545924ca1 ("mm: Rename SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU")

interacting with commit

  ac7138746e14 ("smc: establish new socket family")

from the net-next tree.

I have applied the following merge fix patch (someone will need to
remember to mention this to Linus):

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 19 Jan 2017 14:29:12 +1100
Subject: [PATCH] smc: merge fix for "mm: Rename SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU"

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/smc/af_smc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 4875e65f0c4a..a48260f9ebb7 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -99,7 +99,7 @@ struct proto smc_proto = {
 	.unhash		= smc_unhash_sk,
 	.obj_size	= sizeof(struct smc_sock),
 	.h.smc_hash	= &smc_v4_hashinfo,
-	.slab_flags	= SLAB_DESTROY_BY_RCU,
+	.slab_flags	= SLAB_TYPESAFE_BY_RCU,
 };
 EXPORT_SYMBOL_GPL(smc_proto);
 
-- 
2.10.2

-- 
Cheers,
Stephen Rothwell
