From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: macvlan: Remove the rcu member of macvlan_port
Date: Wed,  7 Dec 2016 12:23:18 +0800
Message-ID: <1481084598-17351-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
        gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg342.qq.com ([14.17.44.37]:50509 "EHLO smtpbg342.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752104AbcLGEYM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 23:24:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

When free macvlan_port in macvlan_port_destroy, it is safe to free
directly because netdev_rx_handler_unregister could enforce one
grace period.
So it is unnecessary to use kfree_rcu for macvlan_port.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/macvlan.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 3c0a171..20b3fdf2 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -43,7 +43,6 @@ struct macvlan_port {
 	struct net_device	*dev;
 	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
 	struct list_head	vlans;
-	struct rcu_head		rcu;
 	struct sk_buff_head	bc_queue;
 	struct work_struct	bc_work;
 	bool 			passthru;
@@ -1151,7 +1150,7 @@ static void macvlan_port_destroy(struct net_device *dev)
 	cancel_work_sync(&port->bc_work);
 	__skb_queue_purge(&port->bc_queue);
 
-	kfree_rcu(port, rcu);
+	kfree(port);
 }
 
 static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
-- 
1.9.1
