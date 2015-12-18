From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 08/14] caif: use list_for_each_entry_safe
Date: Fri, 18 Dec 2015 23:33:32 +0800
Message-ID: <9d0856e9713c935fe0df7449acbe6289c87e5d43.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use list_for_each_entry_safe() instead of list_for_each_safe() to
simplify the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/caif/chnl_net.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 67a4a36..d3db77c 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -140,13 +140,10 @@ static int delete_device(struct chnl_net *dev)
 
 static void close_work(struct work_struct *work)
 {
-	struct chnl_net *dev = NULL;
-	struct list_head *list_node;
-	struct list_head *_tmp;
+	struct chnl_net *dev = NULL, *tmp;
 
 	rtnl_lock();
-	list_for_each_safe(list_node, _tmp, &chnl_net_list) {
-		dev = list_entry(list_node, struct chnl_net, list_field);
+	list_for_each_entry_safe(dev, tmp, &chnl_net_list, list_field) {
 		if (dev->state == CAIF_SHUTDOWN)
 			dev_close(dev->netdev);
 	}
@@ -535,14 +532,11 @@ static int __init chnl_init_module(void)
 
 static void __exit chnl_exit_module(void)
 {
-	struct chnl_net *dev = NULL;
-	struct list_head *list_node;
-	struct list_head *_tmp;
+	struct chnl_net *dev = NULL, *tmp;
 	rtnl_link_unregister(&ipcaif_link_ops);
 	rtnl_lock();
-	list_for_each_safe(list_node, _tmp, &chnl_net_list) {
-		dev = list_entry(list_node, struct chnl_net, list_field);
-		list_del(list_node);
+	list_for_each_entry_safe(dev, tmp, &chnl_net_list, list_field) {
+		list_del(&dev->list_field);
 		delete_device(dev);
 	}
 	rtnl_unlock();
-- 
2.5.0
