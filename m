From: Vasiliy Kulikov <segooon@gmail.com>
Subject: [PATCH 2/9] rionet: use free_netdev(netdev) instead of kfree()
Date: Sun, 26 Sep 2010 13:58:03 +0400
Message-ID: <1285495083-21899-1-git-send-email-segooon@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Freeing netdev without free_netdev() leads to net, tx leaks.
I might lead to dereferencing freed pointer.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

@@
struct net_device* dev;
@@

-kfree(dev)
+free_netdev(dev)
---
 drivers/net/rionet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index 07eb884..44150f2 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -384,7 +384,7 @@ static void rionet_remove(struct rio_dev *rdev)
 	free_pages((unsigned long)rionet_active, rdev->net->hport->sys_size ?
 					__ilog2(sizeof(void *)) + 4 : 0);
 	unregister_netdev(ndev);
-	kfree(ndev);
+	free_netdev(ndev);
 
 	list_for_each_entry_safe(peer, tmp, &rionet_peers, node) {
 		list_del(&peer->node);
-- 
1.7.0.4
