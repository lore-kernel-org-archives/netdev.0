From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 10/14] lapb: use list_for_each_entry
Date: Fri, 18 Dec 2015 23:33:34 +0800
Message-ID: <8052477babbd71d4024331fa804bbf7cb9b60ad1.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use list_for_each_entry() instead of list_for_each() to simplify
the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/lapb/lapb_iface.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/lapb/lapb_iface.c b/net/lapb/lapb_iface.c
index fc60d9d..49abba7 100644
--- a/net/lapb/lapb_iface.c
+++ b/net/lapb/lapb_iface.c
@@ -86,11 +86,9 @@ static void __lapb_insert_cb(struct lapb_cb *lapb)
 
 static struct lapb_cb *__lapb_devtostruct(struct net_device *dev)
 {
-	struct list_head *entry;
 	struct lapb_cb *lapb, *use = NULL;
 
-	list_for_each(entry, &lapb_list) {
-		lapb = list_entry(entry, struct lapb_cb, node);
+	list_for_each_entry(lapb, &lapb_list, node) {
 		if (lapb->dev == dev) {
 			use = lapb;
 			break;
-- 
2.5.0
