From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 6/6] enic: whitespace cleanup; #define cleanup;
	more verbose err msg
Date: Wed, 23 Dec 2009 15:27:59 -0800
Message-ID: <20091223232759.19428.32266.stgit@savbu-pc100.cisco.com>
References: <20091223232551.19428.18916.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:29180 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755874AbZLWX2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:28:00 -0500
In-Reply-To: <20091223232551.19428.18916.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Some misc changes to cleanup whitespace issues and fix/remove some #define
HW defintions.

1) fix some whitespace issues
2) more verbose err msg when resources aren't available to configure vnic
3) remove unused #define
4) fix RSS #define rss hash types

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |    5 +++--
 drivers/net/enic/vnic_dev.c  |    1 -
 drivers/net/enic/vnic_nic.h  |   12 ++++++------
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index e56f416..d87935a 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -731,7 +731,7 @@ static inline void enic_queue_wq_skb(struct enic *enic,
 
 /* netif_tx_lock held, process context with BHs disabled, or BH */
 static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
-					      struct net_device *netdev)
+	struct net_device *netdev)
 {
 	struct enic *enic = netdev_priv(netdev);
 	struct vnic_wq *wq = &enic->wq[0];
@@ -1824,7 +1824,8 @@ int enic_dev_init(struct enic *enic)
 	err = enic_set_intr_mode(enic);
 	if (err) {
 		printk(KERN_ERR PFX
-			"Failed to set intr mode, aborting.\n");
+			"Failed to set intr mode based on resource "
+			"counts and system capabilities, aborting.\n");
 		return err;
 	}
 
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 29a48e8..69b9b70 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -36,7 +36,6 @@ struct vnic_res {
 };
 
 #define VNIC_DEV_CAP_INIT	0x0001
-#define VNIC_DEV_CAP_PERBI	0x0002
 
 struct vnic_dev {
 	void *priv;
diff --git a/drivers/net/enic/vnic_nic.h b/drivers/net/enic/vnic_nic.h
index eeaf329..cf80ab4 100644
--- a/drivers/net/enic/vnic_nic.h
+++ b/drivers/net/enic/vnic_nic.h
@@ -41,12 +41,12 @@
 #define NIC_CFG_IG_VLAN_STRIP_EN_MASK_FIELD	1UL
 #define NIC_CFG_IG_VLAN_STRIP_EN_SHIFT		24
 
-#define NIC_CFG_RSS_HASH_TYPE_IPV4		(1 << 0)
-#define NIC_CFG_RSS_HASH_TYPE_TCP_IPV4		(1 << 1)
-#define NIC_CFG_RSS_HASH_TYPE_IPV6		(1 << 2)
-#define NIC_CFG_RSS_HASH_TYPE_TCP_IPV6		(1 << 3)
-#define NIC_CFG_RSS_HASH_TYPE_IPV6_EX		(1 << 4)
-#define NIC_CFG_RSS_HASH_TYPE_TCP_IPV6_EX	(1 << 5)
+#define NIC_CFG_RSS_HASH_TYPE_IPV4		(1 << 1)
+#define NIC_CFG_RSS_HASH_TYPE_TCP_IPV4		(1 << 2)
+#define NIC_CFG_RSS_HASH_TYPE_IPV6		(1 << 3)
+#define NIC_CFG_RSS_HASH_TYPE_TCP_IPV6		(1 << 4)
+#define NIC_CFG_RSS_HASH_TYPE_IPV6_EX		(1 << 5)
+#define NIC_CFG_RSS_HASH_TYPE_TCP_IPV6_EX	(1 << 6)
 
 static inline void vnic_set_nic_cfg(u32 *nic_cfg,
 	u8 rss_default_cpu, u8 rss_hash_type,

