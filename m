From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 03/36] net,rcu: convert call_rcu(fc_rport_free_rcu) to kfree_rcu()
Date: Fri, 18 Mar 2011 11:42:11 +0800
Message-ID: <4D82D493.3080504@cn.fujitsu.com>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <James.Bottom
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56395 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932090Ab1CRDk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:40:27 -0400
In-Reply-To: <4D82D3FF.2080303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback fc_rport_free_rcu() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(fc_rport_free_rcu).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/ipv4/fib_semantics.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 12d3dc3..730c03e 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -145,16 +145,8 @@ static const struct
 	},
 };
 
-
 /* Release a nexthop info record */
 
-static void free_fib_info_rcu(struct rcu_head *head)
-{
-	struct fib_info *fi = container_of(head, struct fib_info, rcu);
-
-	kfree(fi);
-}
-
 void free_fib_info(struct fib_info *fi)
 {
 	if (fi->fib_dead == 0) {
@@ -168,7 +160,7 @@ void free_fib_info(struct fib_info *fi)
 	} endfor_nexthops(fi);
 	fib_info_cnt--;
 	release_net(fi->fib_net);
-	call_rcu(&fi->rcu, free_fib_info_rcu);
+	kfree_rcu(fi, rcu);
 }
 
 void fib_release_info(struct fib_info *fi)
-- 
1.7.4
