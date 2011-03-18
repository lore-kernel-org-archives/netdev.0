From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 30/36] net,rcu: convert call_rcu(wq_free_rcu) to kfree_rcu()
Date: Fri, 18 Mar 2011 12:10:25 +0800
Message-ID: <4D82DB31.7050007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49525 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752821Ab1CREIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 00:08:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback wq_free_rcu() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(wq_free_rcu).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/socket.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index ac2219f..3158271 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -261,21 +261,12 @@ static struct inode *sock_alloc_inode(struct super_block *sb)
 	return &ei->vfs_inode;
 }
 
-
-
-static void wq_free_rcu(struct rcu_head *head)
-{
-	struct socket_wq *wq = container_of(head, struct socket_wq, rcu);
-
-	kfree(wq);
-}
-
 static void sock_destroy_inode(struct inode *inode)
 {
 	struct socket_alloc *ei;
 
 	ei = container_of(inode, struct socket_alloc, vfs_inode);
-	call_rcu(&ei->socket.wq->rcu, wq_free_rcu);
+	kfree_rcu(ei->socket.wq, rcu);
 	kmem_cache_free(sock_inode_cachep, ei);
 }
 
-- 
1.7.4
