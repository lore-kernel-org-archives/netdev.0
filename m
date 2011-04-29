From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH 1/2] net: use NETIF_F_ALL_TSO for vlan features
Date: Fri, 29 Apr 2011 13:20:52 +0800
Message-ID: <4DBA4AB4.5000802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, eilong@broadcom.com,
	dm@chelsio.com, leedom@chelsio.com, mirqus@gmail.com,
	bhutchings@solarflare.com, dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57372 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751842Ab1D2FY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2011 01:24:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As Dimitris Michailidis suggested, use NETIF_F_ALL_TSO for vlan_features,
which is a mask, but not hw_features. 

Compile test.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 drivers/net/bnx2x/bnx2x_main.c     |    2 +-
 drivers/net/cxgb4/cxgb4_main.c     |    2 +-
 drivers/net/cxgb4vf/cxgb4vf_main.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index bfd7ac9..67b1011 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -9429,7 +9429,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_HW_VLAN_TX;
 
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
+		NETIF_F_ALL_TSO | NETIF_F_HIGHDMA;
 
 	dev->features |= dev->hw_features | NETIF_F_HW_VLAN_RX;
 	if (bp->flags & USING_DAC_FLAG)
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index bdc868c..d6b1a91 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -3526,7 +3526,7 @@ static void free_some_resources(struct adapter *adapter)
 }
 
 #define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
-#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
+#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_ALL_TSO | \
 		   NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
 
 static int __devinit init_one(struct pci_dev *pdev,
diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 8cf9890..b735c52 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -2603,7 +2603,7 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 		netdev->hw_features = NETIF_F_SG | TSO_FLAGS |
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			NETIF_F_HW_VLAN_TX | NETIF_F_RXCSUM;
-		netdev->vlan_features = NETIF_F_SG | TSO_FLAGS |
+		netdev->vlan_features = NETIF_F_SG | NETIF_F_ALL_TSO |
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			NETIF_F_HIGHDMA;
 		netdev->features = netdev->hw_features |
-- 
1.7.3.1
