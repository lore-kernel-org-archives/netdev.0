From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH]bnx2: Add NETIF_F_TSO_ECN
Date: Tue, 27 Jun 2006 20:07:04 -0700
Message-ID: <1151464024.5124.14.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:6152 "EHLO mms2.broadcom.com")
	by vger.kernel.org with ESMTP id S1423001AbWF1DF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 23:05:59 -0400
To: davem@davemloft.net, herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add NETIF_F_TSO_ECN feature for all bnx2 hardware.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7635736..e89d5df 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5128,6 +5128,16 @@ bnx2_set_rx_csum(struct net_device *dev,
 	return 0;
 }
 
+static int
+bnx2_set_tso(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN;
+	else
+		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
+	return 0;
+}
+
 #define BNX2_NUM_STATS 46
 
 static struct {
@@ -5445,7 +5455,7 @@ static struct ethtool_ops bnx2_ethtool_o
 	.set_sg			= ethtool_op_set_sg,
 #ifdef BCM_TSO
 	.get_tso		= ethtool_op_get_tso,
-	.set_tso		= ethtool_op_set_tso,
+	.set_tso		= bnx2_set_tso,
 #endif
 	.self_test_count	= bnx2_self_test_count,
 	.self_test		= bnx2_self_test,
@@ -5926,7 +5936,7 @@ bnx2_init_one(struct pci_dev *pdev, cons
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 #endif
 #ifdef BCM_TSO
-	dev->features |= NETIF_F_TSO;
+	dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN;
 #endif
 
 	netif_carrier_off(bp->dev);


