From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH net-next v9 5/9] net: bond - make bond_create take name_assign_type
Date: Thu, 17 Jul 2014 10:06:06 +0200
Message-ID: <1405584370-30054-6-git-send-email-teg@jklm.no>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405584370-30054-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/bonding/bond_main.c  | 7 ++++---
 drivers/net/bonding/bond_sysfs.c | 2 +-
 drivers/net/bonding/bonding.h    | 2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d643807..1769745 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4421,7 +4421,7 @@ unsigned int bond_get_num_tx_queues(void)
  * Caller must NOT hold rtnl_lock; we need to release it here before we
  * set up our sysfs entries.
  */
-int bond_create(struct net *net, const char *name)
+int bond_create(struct net *net, const char *name, unsigned char name_assign_type)
 {
 	struct net_device *bond_dev;
 	int res;
@@ -4429,7 +4429,8 @@ int bond_create(struct net *net, const char *name)
 	rtnl_lock();
 
 	bond_dev = alloc_netdev_mq(sizeof(struct bonding),
-				   name ? name : "bond%d", NET_NAME_UNKNOWN,
+				   name ? name : "bond%d",
+				   name ? name_assign_type : NET_NAME_ENUM,
 				   bond_setup, tx_queues);
 	if (!bond_dev) {
 		pr_err("%s: eek! can't alloc netdev!\n", name);
@@ -4509,7 +4510,7 @@ static int __init bonding_init(void)
 	bond_create_debugfs();
 
 	for (i = 0; i < max_bonds; i++) {
-		res = bond_create(&init_net, NULL);
+		res = bond_create(&init_net, NULL, NET_NAME_UNKNOWN);
 		if (res)
 			goto err;
 	}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 98db8ed..7ac498c 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -111,7 +111,7 @@ static ssize_t bonding_store_bonds(struct class *cls,
 
 	if (command[0] == '+') {
 		pr_info("%s is being created...\n", ifname);
-		rv = bond_create(bn->net, ifname);
+		rv = bond_create(bn->net, ifname, NET_NAME_USER);
 		if (rv) {
 			if (rv == -EEXIST)
 				pr_info("%s already exists\n", ifname);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b2e548e..95b5e70 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -496,7 +496,7 @@ struct bond_net {
 
 int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond, struct slave *slave);
 void bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
-int bond_create(struct net *net, const char *name);
+int bond_create(struct net *net, const char *name, unsigned char name_assign_type);
 int bond_create_sysfs(struct bond_net *net);
 void bond_destroy_sysfs(struct bond_net *net);
 void bond_prepare_sysfs_group(struct bonding *bond);
-- 
1.9.3
