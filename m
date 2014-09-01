From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 08/12] be2net: define BE_MAX_MTU
Date: Mon, 1 Sep 2014 11:54:20 +0530
Message-ID: <1409552664-15990-9-git-send-email-sathya.perla@emulex.com>
References: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:22507 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297AbaIAGV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 02:21:58 -0400
In-Reply-To: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This patch defines a new macro BE_MAX_MTU to make the code in be_change_mtu()
more readable.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    2 ++
 drivers/net/ethernet/emulex/benet/be_main.c |   14 +++++++-------
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 069bdda..5ccfce7 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -86,6 +86,8 @@ static inline char *nic_name(struct pci_dev *pdev)
 
 #define BE_MAX_JUMBO_FRAME_SIZE	9018
 #define BE_MIN_MTU		256
+#define BE_MAX_MTU              (BE_MAX_JUMBO_FRAME_SIZE -	\
+				 (ETH_HLEN + ETH_FCS_LEN))
 
 #define BE_NUM_VLANS_SUPPORTED	64
 #define BE_MAX_EQD		128u
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index cdad8bc..04a8092 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1073,15 +1073,15 @@ static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
 static int be_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	if (new_mtu < BE_MIN_MTU ||
-	    new_mtu > (BE_MAX_JUMBO_FRAME_SIZE - (ETH_HLEN + ETH_FCS_LEN))) {
-		dev_info(&adapter->pdev->dev,
-			 "MTU must be between %d and %d bytes\n",
-			 BE_MIN_MTU,
-			 (BE_MAX_JUMBO_FRAME_SIZE - (ETH_HLEN + ETH_FCS_LEN)));
+	struct device *dev = &adapter->pdev->dev;
+
+	if (new_mtu < BE_MIN_MTU || new_mtu > BE_MAX_MTU) {
+		dev_info(dev, "MTU must be between %d and %d bytes\n",
+			 BE_MIN_MTU, BE_MAX_MTU);
 		return -EINVAL;
 	}
-	dev_info(&adapter->pdev->dev, "MTU changed from %d to %d bytes\n",
+
+	dev_info(dev, "MTU changed from %d to %d bytes\n",
 		 netdev->mtu, new_mtu);
 	netdev->mtu = new_mtu;
 	return 0;
-- 
1.7.1
