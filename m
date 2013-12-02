From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: do not pretend FRAGLIST support
Date: Mon, 02 Dec 2013 08:51:13 -0800
Message-ID: <1386003073.5352.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385631882-12827-2-git-send-email-puzman@gmail.com>
	 <20131129.164229.2292905485668904870.davem@davemloft.net>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B744F@saturn3.aculab.com>
	 <20131202.111600.1622488165507147936.davem@davemloft.net>
	 <1386001999.5352.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, puzman@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Anirudha Sarangi <anirudh@xilinx.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386001999.5352.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

Few network drivers really supports frag_list : virtual drivers.

Some drivers wrongly advertise NETIF_F_FRAGLIST feature.

If skb with a frag_list is given to them, packet on the wire will be
corrupt.

Remove this flag, as core networking stack will make sure to
provide packets that can be sent without corruption.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Cc: Anirudha Sarangi <anirudh@xilinx.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c         |    2 +-
 drivers/net/ethernet/tehuti/tehuti.c              |    1 -
 drivers/net/ethernet/xilinx/ll_temac_main.c       |    2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    2 +-
 4 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 2d1c6bdd3618..7628e0fd8455 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3033,7 +3033,7 @@ static struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 
 	dev->hw_features = NETIF_F_SG | NETIF_F_TSO |
 		      NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_CTAG_TX;
-	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO |
+	dev->features = NETIF_F_SG | NETIF_F_TSO |
 		      NETIF_F_HIGHDMA | NETIF_F_IP_CSUM |
 		      NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
 		      NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_RXCSUM;
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index dd0dd6279b4e..4f1d2549130e 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -2019,7 +2019,6 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		ndev->features = NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO
 		    | NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
 		    NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_RXCSUM
-		    /*| NETIF_F_FRAGLIST */
 		    ;
 		ndev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_HW_VLAN_CTAG_TX;
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 1f2364126323..2166e879a096 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1017,7 +1017,7 @@ static int temac_of_probe(struct platform_device *op)
 	platform_set_drvdata(op, ndev);
 	SET_NETDEV_DEV(ndev, &op->dev);
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
-	ndev->features = NETIF_F_SG | NETIF_F_FRAGLIST;
+	ndev->features = NETIF_F_SG;
 	ndev->netdev_ops = &temac_netdev_ops;
 	ndev->ethtool_ops = &temac_ethtool_ops;
 #if 0
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index b2ff038d6d20..f9293da19e26 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1486,7 +1486,7 @@ static int axienet_of_probe(struct platform_device *op)
 
 	SET_NETDEV_DEV(ndev, &op->dev);
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
-	ndev->features = NETIF_F_SG | NETIF_F_FRAGLIST;
+	ndev->features = NETIF_F_SG;
 	ndev->netdev_ops = &axienet_netdev_ops;
 	ndev->ethtool_ops = &axienet_ethtool_ops;
 
