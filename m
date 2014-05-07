From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/3] bonding: remove the unnecessary struct bond_net
Date: Wed, 7 May 2014 11:45:17 +0800
Message-ID: <1399434319-7300-2-git-send-email-dingtianhong@huawei.com>
References: <1399434319-7300-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:21276 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbaEGDpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 23:45:46 -0400
In-Reply-To: <1399434319-7300-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the structure bond_net forward, and remove the unnecessary structure declaration.

Cc: Ding Tianhong <dingtianhong@huawei.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bonding.h | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b8bdd0a..9f23bf3 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -487,7 +487,14 @@ static inline bool slave_can_tx(struct slave *slave)
 		return false;
 }
 
-struct bond_net;
+struct bond_net {
+	struct net *		net;	/* Associated network namespace */
+	struct list_head	dev_list;
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *	proc_dir;
+#endif
+	struct class_attribute	class_attr_bonding_masters;
+};
 
 int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond, struct slave *slave);
 void bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
@@ -516,15 +523,6 @@ struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 const char *bond_slave_link_status(s8 link);
 
-struct bond_net {
-	struct net *		net;	/* Associated network namespace */
-	struct list_head	dev_list;
-#ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *	proc_dir;
-#endif
-	struct class_attribute	class_attr_bonding_masters;
-};
-
 #ifdef CONFIG_PROC_FS
 void bond_create_proc_entry(struct bonding *bond);
 void bond_remove_proc_entry(struct bonding *bond);
-- 
1.8.0
