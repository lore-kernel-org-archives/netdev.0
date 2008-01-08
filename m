From: linux@horizon.com
Subject: [PATCH 2/3] drivers/net/ipg.c: convert Jumbo.FoundStart to bool
Date: 8 Jan 2008 07:32:16 -0500
Message-ID: <20080108123216.12055.qmail@science.horizon.com>
Cc: akpm@linux-foundation.org, davem@davemloft.net, linux@horizon.com
To: netdev@vger.kernel.org, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:19700 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755794AbYAHN2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 08:28:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a fairly basic code cleanup that annoyed me while working
on the first patch.
---
diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
index d5d092c..5d7cc84 100644
--- a/drivers/net/ipg.h
+++ b/drivers/net/ipg.h
@@ -789,11 +789,6 @@ struct ipg_rx {
 	__le64 frag_info;
 };
 
-struct SJumbo {
-	int FoundStart;
-	int CurrentSize;
-	struct sk_buff *skb;
-};
 /* Structure of IPG NIC specific data. */
 struct ipg_nic_private {
 	void __iomem *ioaddr;
@@ -809,7 +804,11 @@ struct ipg_nic_private {
 	unsigned int rx_dirty;
 // Add by Grace 2005/05/19
 #ifdef JUMBO_FRAME
-	struct SJumbo Jumbo;
+	struct SJumbo {
+		bool FoundStart;
+		int CurrentSize;
+		struct sk_buff *skb;
+	} Jumbo;
 #endif
 	unsigned int rx_buf_sz;
 	struct pci_dev *pdev;
diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
index d5d092c..5d7cc84 100644
--- a/drivers/net/ipg.h
+++ b/drivers/net/ipg.h
@@ -789,11 +789,6 @@ struct ipg_rx {
 	__le64 frag_info;
 };
 
-struct SJumbo {
-	int FoundStart;
-	int CurrentSize;
-	struct sk_buff *skb;
-};
 /* Structure of IPG NIC specific data. */
 struct ipg_nic_private {
 	void __iomem *ioaddr;
@@ -809,7 +804,11 @@ struct ipg_nic_private {
 	unsigned int rx_dirty;
 // Add by Grace 2005/05/19
 #ifdef JUMBO_FRAME
-	struct SJumbo Jumbo;
+	struct SJumbo {
+		bool FoundStart;
+		int CurrentSize;
+		struct sk_buff *skb;
+	} Jumbo;
 #endif
 	unsigned int rx_buf_sz;
 	struct pci_dev *pdev;
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index a0dfba5..3860fcd 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -1206,7 +1206,7 @@ static void ipg_nic_rx_with_start_and_end(struct net_device *dev,
 
 	if (jumbo->FoundStart) {
 		IPG_DEV_KFREE_SKB(jumbo->skb);
-		jumbo->FoundStart = 0;
+		jumbo->FoundStart = false;
 		jumbo->CurrentSize = 0;
 		jumbo->skb = NULL;
 	}
@@ -1257,7 +1257,7 @@ static void ipg_nic_rx_with_start(struct net_device *dev,
 
 	skb_put(skb, IPG_RXFRAG_SIZE);
 
-	jumbo->FoundStart = 1;
+	jumbo->FoundStart = true;
 	jumbo->CurrentSize = IPG_RXFRAG_SIZE;
 	jumbo->skb = skb;
 
@@ -1303,14 +1303,14 @@ static void ipg_nic_rx_with_end(struct net_device *dev,
 		}
 
 		dev->last_rx = jiffies;
-		jumbo->FoundStart = 0;
+		jumbo->FoundStart = false;
 		jumbo->CurrentSize = 0;
 		jumbo->skb = NULL;
 
 		ipg_nic_rx_free_skb(dev, entry);
 	} else {
 		IPG_DEV_KFREE_SKB(jumbo->skb);
-		jumbo->FoundStart = 0;
+		jumbo->FoundStart = false;
 		jumbo->CurrentSize = 0;
 		jumbo->skb = NULL;
 	}
@@ -1340,7 +1340,7 @@ static void ipg_nic_rx_no_start_no_end(struct net_device *dev,
 		}
 	} else {
 		IPG_DEV_KFREE_SKB(jumbo->skb);
-		jumbo->FoundStart = 0;
+		jumbo->FoundStart = false;
 		jumbo->CurrentSize = 0;
 		jumbo->skb = NULL;
 	}
@@ -1840,7 +1840,7 @@ static int ipg_nic_open(struct net_device *dev)
 
 #ifdef JUMBO_FRAME
 	/* initialize JUMBO Frame control variable */
-	sp->Jumbo.FoundStart = 0;
+	sp->Jumbo.FoundStart = false;
 	sp->Jumbo.CurrentSize = 0;
 	sp->Jumbo.skb = 0;
 	dev->mtu = IPG_TXFRAG_SIZE;
