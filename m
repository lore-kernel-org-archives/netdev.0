From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [net-next PATCH 3/5] qlge: Removing needless print's which are
 not
Date: Fri, 3 Feb 2012 17:28:15 -0800
Message-ID: <5E4F49720D0BAD499EE1F01232234BA87437BA0591@AVEXMB1.qlogic.org>
References: <1328314013-20458-1-git-send-email-jitendra.kalsaria@qlogic.com>
 <1328314013-20458-3-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:49959 "EHLO
	TX2EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752588Ab2BDBnY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 20:43:24 -0500
In-Reply-To: <1328314013-20458-3-git-send-email-jitendra.kalsaria@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Just to let you know that this patch is a replacement of previously rejected patch "[net PATCH 1/1] qlge:Changing netdev msg level to default debug".

Jiten

-----Original Message-----
From: Jitendra Kalsaria [mailto:jitendra.kalsaria@qlogic.com] 
Sent: Friday, February 03, 2012 4:07 PM
To: David Miller
Cc: netdev; Ron Mercer; Dept-NX Linux NIC Driver; Jitendra Kalsaria
Subject: [net-next PATCH 3/5] qlge: Removing needless print's which are not

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   71 +-------------------------
 1 files changed, 1 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 582b237..af12e80 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -375,13 +375,6 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 			u32 lower =
 			    (addr[2] << 24) | (addr[3] << 16) | (addr[4] << 8) |
 			    (addr[5]);
-
-			netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
-				     "Adding %s address %pM at index %d in the CAM.\n",
-				     type == MAC_ADDR_TYPE_MULTI_MAC ?
-				     "MULTICAST" : "UNICAST",
-				     addr, index);
-
 			status =
 			    ql_wait_reg_rdy(qdev,
 				MAC_ADDR_IDX, MAC_ADDR_MW, 0);
@@ -430,12 +423,6 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 			 * addressing. It's either MAC_ADDR_E on or off.
 			 * That's bit-27 we're talking about.
 			 */
-			netif_info(qdev, ifup, qdev->ndev,
-				   "%s VLAN ID %d %s the CAM.\n",
-				   enable_bit ? "Adding" : "Removing",
-				   index,
-				   enable_bit ? "to" : "from");
-
 			status =
 			    ql_wait_reg_rdy(qdev,
 				MAC_ADDR_IDX, MAC_ADDR_MW, 0);
@@ -535,28 +522,6 @@ static int ql_set_routing_reg(struct ql_adapter *qdev, u32 index, u32 mask,
 	int status = -EINVAL; /* Return error if no mask match. */
 	u32 value = 0;
 
-	netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
-		     "%s %s mask %s the routing reg.\n",
-		     enable ? "Adding" : "Removing",
-		     index == RT_IDX_ALL_ERR_SLOT ? "MAC ERROR/ALL ERROR" :
-		     index == RT_IDX_IP_CSUM_ERR_SLOT ? "IP CSUM ERROR" :
-		     index == RT_IDX_TCP_UDP_CSUM_ERR_SLOT ? "TCP/UDP CSUM ERROR" :
-		     index == RT_IDX_BCAST_SLOT ? "BROADCAST" :
-		     index == RT_IDX_MCAST_MATCH_SLOT ? "MULTICAST MATCH" :
-		     index == RT_IDX_ALLMULTI_SLOT ? "ALL MULTICAST MATCH" :
-		     index == RT_IDX_UNUSED6_SLOT ? "UNUSED6" :
-		     index == RT_IDX_UNUSED7_SLOT ? "UNUSED7" :
-		     index == RT_IDX_RSS_MATCH_SLOT ? "RSS ALL/IPV4 MATCH" :
-		     index == RT_IDX_RSS_IPV6_SLOT ? "RSS IPV6" :
-		     index == RT_IDX_RSS_TCP4_SLOT ? "RSS TCP4" :
-		     index == RT_IDX_RSS_TCP6_SLOT ? "RSS TCP6" :
-		     index == RT_IDX_CAM_HIT_SLOT ? "CAM HIT" :
-		     index == RT_IDX_UNUSED013 ? "UNUSED13" :
-		     index == RT_IDX_UNUSED014 ? "UNUSED14" :
-		     index == RT_IDX_PROMISCUOUS_SLOT ? "PROMISCUOUS" :
-		     "(Bad index != RT_IDX)",
-		     enable ? "to" : "from");
-
 	switch (mask) {
 	case RT_IDX_CAM_HIT:
 		{
@@ -2313,13 +2278,9 @@ static void qlge_vlan_mode(struct net_device *ndev, netdev_features_t features)
 	struct ql_adapter *qdev = netdev_priv(ndev);
 
 	if (features & NETIF_F_HW_VLAN_RX) {
-		netif_printk(qdev, ifup, KERN_DEBUG, ndev,
-			     "Turning on VLAN in NIC_RCV_CFG.\n");
 		ql_write32(qdev, NIC_RCV_CFG, NIC_RCV_CFG_VLAN_MASK |
 				 NIC_RCV_CFG_VLAN_MATCH_AND_NON);
 	} else {
-		netif_printk(qdev, ifup, KERN_DEBUG, ndev,
-			     "Turning off VLAN in NIC_RCV_CFG.\n");
 		ql_write32(qdev, NIC_RCV_CFG, NIC_RCV_CFG_VLAN_MASK);
 	}
 }
@@ -3184,8 +3145,6 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
 			     "Invalid rx_ring->type = %d.\n", rx_ring->type);
 	}
-	netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
-		     "Initializing rx work queue.\n");
 	err = ql_write_cfg(qdev, cqicb, sizeof(struct cqicb),
 			   CFG_LCQ, rx_ring->cq_id);
 	if (err) {
@@ -3238,8 +3197,6 @@ static int ql_start_tx_ring(struct ql_adapter *qdev, struct tx_ring *tx_ring)
 		netif_err(qdev, ifup, qdev->ndev, "Failed to load tx_ring.\n");
 		return err;
 	}
-	netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
-		     "Successfully loaded WQICB.\n");
 	return err;
 }
 
@@ -3489,12 +3446,8 @@ static void ql_free_irq(struct ql_adapter *qdev)
 			if (test_bit(QL_MSIX_ENABLED, &qdev->flags)) {
 				free_irq(qdev->msi_x_entry[i].vector,
 					 &qdev->rx_ring[i]);
-				netif_printk(qdev, ifdown, KERN_DEBUG, qdev->ndev,
-					     "freeing msix interrupt %d.\n", i);
 			} else {
 				free_irq(qdev->pdev->irq, &qdev->rx_ring[0]);
-				netif_printk(qdev, ifdown, KERN_DEBUG, qdev->ndev,
-					     "freeing msi interrupt %d.\n", i);
 			}
 		}
 	}
@@ -3523,17 +3476,6 @@ static int ql_request_irq(struct ql_adapter *qdev)
 					  "Failed request for MSIX interrupt %d.\n",
 					  i);
 				goto err_irq;
-			} else {
-				netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
-					     "Hooked intr %d, queue type %s, with name %s.\n",
-					     i,
-					     qdev->rx_ring[i].type == DEFAULT_Q ?
-					     "DEFAULT_Q" :
-					     qdev->rx_ring[i].type == TX_Q ?
-					     "TX_Q" :
-					     qdev->rx_ring[i].type == RX_Q ?
-					     "RX_Q" : "",
-					     intr_context->name);
 			}
 		} else {
 			netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
@@ -3603,15 +3545,11 @@ static int ql_start_rss(struct ql_adapter *qdev)
 	memcpy((void *)&ricb->ipv6_hash_key[0], init_hash_seed, 40);
 	memcpy((void *)&ricb->ipv4_hash_key[0], init_hash_seed, 16);
 
-	netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev, "Initializing RSS.\n");
-
 	status = ql_write_cfg(qdev, ricb, sizeof(*ricb), CFG_LR, 0);
 	if (status) {
 		netif_err(qdev, ifup, qdev->ndev, "Failed to load RICB.\n");
 		return status;
 	}
-	netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
-		     "Successfully loaded RICB.\n");
 	return status;
 }
 
@@ -3818,11 +3756,8 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 	}
 
 	/* Start NAPI for the RSS queues. */
-	for (i = 0; i < qdev->rss_ring_count; i++) {
-		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
-			     "Enabling NAPI for rx_ring[%d].\n", i);
+	for (i = 0; i < qdev->rss_ring_count; i++)
 		napi_enable(&qdev->rx_ring[i].napi);
-	}
 
 	return status;
 }
@@ -4122,10 +4057,6 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 			rx_ring->lbq_size =
 			    rx_ring->lbq_len * sizeof(__le64);
 			rx_ring->lbq_buf_size = (u16)lbq_buf_len;
-			netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
-				     "lbq_buf_size %d, order = %d\n",
-				     rx_ring->lbq_buf_size,
-				     qdev->lbq_buf_order);
 			rx_ring->sbq_len = NUM_SMALL_BUFFERS;
 			rx_ring->sbq_size =
 			    rx_ring->sbq_len * sizeof(__le64);
-- 
1.7.6.rc1.1.g2c162b
