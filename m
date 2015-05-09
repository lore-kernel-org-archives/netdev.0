From: sfeldma@gmail.com
Subject: [PATCH net-next v6 22/23] rocker: make checkpatch -f clean
Date: Sat,  9 May 2015 10:40:24 -0700
Message-ID: <1431193225-807-23-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:32946 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbbEIRnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:41 -0400
Received: by pdbnk13 with SMTP id nk13so113200892pdb.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:40 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Well almost clean: ignore the CHECKs for space after cast operator and some
longer-than-80 char cases where for readability it's better to keep as-is.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   19 +++++++++----------
 drivers/net/ethernet/rocker/rocker.h |   28 ++++++++++++++--------------
 2 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 2c2e091..b451f47 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -181,7 +181,7 @@ struct rocker_desc_info {
 	size_t data_size;
 	size_t tlv_size;
 	struct rocker_desc *desc;
-	DEFINE_DMA_UNMAP_ADDR(mapaddr);
+	dma_addr_t mapaddr;
 };
 
 struct rocker_dma_ring_info {
@@ -238,21 +238,21 @@ struct rocker {
 	struct {
 		u64 id;
 	} hw;
-	spinlock_t cmd_ring_lock;
+	spinlock_t cmd_ring_lock;		/* for cmd ring accesses */
 	struct rocker_dma_ring_info cmd_ring;
 	struct rocker_dma_ring_info event_ring;
 	DECLARE_HASHTABLE(flow_tbl, 16);
-	spinlock_t flow_tbl_lock;
+	spinlock_t flow_tbl_lock;		/* for flow tbl accesses */
 	u64 flow_tbl_next_cookie;
 	DECLARE_HASHTABLE(group_tbl, 16);
-	spinlock_t group_tbl_lock;
+	spinlock_t group_tbl_lock;		/* for group tbl accesses */
 	DECLARE_HASHTABLE(fdb_tbl, 16);
-	spinlock_t fdb_tbl_lock;
+	spinlock_t fdb_tbl_lock;		/* for fdb tbl accesses */
 	unsigned long internal_vlan_bitmap[ROCKER_INTERNAL_VLAN_BITMAP_LEN];
 	DECLARE_HASHTABLE(internal_vlan_tbl, 8);
-	spinlock_t internal_vlan_tbl_lock;
+	spinlock_t internal_vlan_tbl_lock;	/* for vlan tbl accesses */
 	DECLARE_HASHTABLE(neigh_tbl, 16);
-	spinlock_t neigh_tbl_lock;
+	spinlock_t neigh_tbl_lock;		/* for neigh tbl accesses */
 	u32 neigh_tbl_next_index;
 };
 
@@ -4643,8 +4643,6 @@ static void rocker_port_get_stats(struct net_device *dev,
 		for (i = 0; i < ARRAY_SIZE(rocker_port_stats); ++i)
 			data[i] = 0;
 	}
-
-	return;
 }
 
 static int rocker_port_get_sset_count(struct net_device *netdev, int sset)
@@ -4698,8 +4696,9 @@ static int rocker_port_poll_tx(struct napi_struct *napi, int budget)
 		if (err == 0) {
 			rocker_port->dev->stats.tx_packets++;
 			rocker_port->dev->stats.tx_bytes += skb->len;
-		} else
+		} else {
 			rocker_port->dev->stats.tx_errors++;
+		}
 
 		dev_kfree_skb_any(skb);
 		credits++;
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index a4e9591..c61fbf9 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -65,9 +65,9 @@ enum {
 #define ROCKER_TEST_DMA_CTRL		0x0034
 
 /* Rocker test register ctrl */
-#define ROCKER_TEST_DMA_CTRL_CLEAR	(1 << 0)
-#define ROCKER_TEST_DMA_CTRL_FILL	(1 << 1)
-#define ROCKER_TEST_DMA_CTRL_INVERT	(1 << 2)
+#define ROCKER_TEST_DMA_CTRL_CLEAR	BIT(0)
+#define ROCKER_TEST_DMA_CTRL_FILL	BIT(1)
+#define ROCKER_TEST_DMA_CTRL_INVERT	BIT(2)
 
 /* Rocker DMA ring register offsets */
 #define ROCKER_DMA_DESC_ADDR(x)		(0x1000 + (x) * 32)  /* 8-byte */
@@ -79,7 +79,7 @@ enum {
 #define ROCKER_DMA_DESC_RES1(x)		(0x101c + (x) * 32)
 
 /* Rocker dma ctrl register bits */
-#define ROCKER_DMA_DESC_CTRL_RESET	(1 << 0)
+#define ROCKER_DMA_DESC_CTRL_RESET	BIT(0)
 
 /* Rocker DMA ring types */
 enum rocker_dma_type {
@@ -111,7 +111,7 @@ struct rocker_desc {
 	u16 comp_err;
 };
 
-#define ROCKER_DMA_DESC_COMP_ERR_GEN	(1 << 15)
+#define ROCKER_DMA_DESC_COMP_ERR_GEN	BIT(15)
 
 /* Rocker DMA TLV struct */
 struct rocker_tlv {
@@ -237,14 +237,14 @@ enum {
 	ROCKER_TLV_RX_MAX = __ROCKER_TLV_RX_MAX - 1,
 };
 
-#define ROCKER_RX_FLAGS_IPV4			(1 << 0)
-#define ROCKER_RX_FLAGS_IPV6			(1 << 1)
-#define ROCKER_RX_FLAGS_CSUM_CALC		(1 << 2)
-#define ROCKER_RX_FLAGS_IPV4_CSUM_GOOD		(1 << 3)
-#define ROCKER_RX_FLAGS_IP_FRAG			(1 << 4)
-#define ROCKER_RX_FLAGS_TCP			(1 << 5)
-#define ROCKER_RX_FLAGS_UDP			(1 << 6)
-#define ROCKER_RX_FLAGS_TCP_UDP_CSUM_GOOD	(1 << 7)
+#define ROCKER_RX_FLAGS_IPV4			BIT(0)
+#define ROCKER_RX_FLAGS_IPV6			BIT(1)
+#define ROCKER_RX_FLAGS_CSUM_CALC		BIT(2)
+#define ROCKER_RX_FLAGS_IPV4_CSUM_GOOD		BIT(3)
+#define ROCKER_RX_FLAGS_IP_FRAG			BIT(4)
+#define ROCKER_RX_FLAGS_TCP			BIT(5)
+#define ROCKER_RX_FLAGS_UDP			BIT(6)
+#define ROCKER_RX_FLAGS_TCP_UDP_CSUM_GOOD	BIT(7)
 
 enum {
 	ROCKER_TLV_TX_UNSPEC,
@@ -460,6 +460,6 @@ enum rocker_of_dpa_overlay_type {
 #define ROCKER_SWITCH_ID		0x0320 /* 8-byte */
 
 /* Rocker control bits */
-#define ROCKER_CONTROL_RESET		(1 << 0)
+#define ROCKER_CONTROL_RESET		BIT(0)
 
 #endif
-- 
1.7.10.4
