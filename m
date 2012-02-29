From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Tue, 28 Feb 2012 19:52:26 -0800
Message-ID: <1330487546.3742.1.camel@joe2Laptop>
References: <1330480210-30470-1-git-send-email-rodrigue@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mcgrof@frijolero.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com,
	kgiori@qca.qualcomm.com, chris.snook@gmail.com,
	mathieu@qca.qualcomm.com, bryanh@quicinc.com
To: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:51515 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757383Ab2B2Dw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Feb 2012 22:52:29 -0500
In-Reply-To: <1330480210-30470-1-git-send-email-rodrigue@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even though this whole thing has been rejected,
here are some possible trivial logging corrections.
---
 drivers/net/ethernet/atheros/alx/alf_cb.c   |    2 +-
 drivers/net/ethernet/atheros/alx/alx_main.c |   63 ++++++++++++---------------
 drivers/net/ethernet/atheros/alx/alx_sw.h   |    4 +-
 3 files changed, 31 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/alf_cb.c b/drivers/net/ethernet/atheros/alx/alf_cb.c
index d267760..9e823f6 100644
--- a/drivers/net/ethernet/atheros/alx/alf_cb.c
+++ b/drivers/net/ethernet/atheros/alx/alf_cb.c
@@ -274,7 +274,7 @@ static int alf_check_phy_link(struct alx_hw *hw, u32 *speed, bool *link_up)
 		if (giga & L1F_GIGA_PSSR_DPLX)
 			*speed = ALX_LINK_SPEED_1GB_FULL;
 		else
-			alx_hw_err(hw, "1000M half is invalid");
+			alx_hw_err(hw, "1000M half is invalid\n");
 		break;
 	case L1F_GIGA_PSSR_100MBS:
 		if (giga & L1F_GIGA_PSSR_DPLX)
diff --git a/drivers/net/ethernet/atheros/alx/alx_main.c b/drivers/net/ethernet/atheros/alx/alx_main.c
index a51c608..a599269 100644
--- a/drivers/net/ethernet/atheros/alx/alx_main.c
+++ b/drivers/net/ethernet/atheros/alx/alx_main.c
@@ -19,8 +19,7 @@
 
 char alx_drv_name[] = "alx";
 static const char alx_drv_description[] =
-	"Qualcomm Atheros(R) "
-	"AR813x/AR815x/AR816x PCI-E Ethernet Network Driver";
+	"Qualcomm Atheros(R) AR813x/AR815x/AR816x PCI-E Ethernet Network Driver";
 
 /* alx_pci_tbl - PCI Device ID Table
  *
@@ -142,22 +141,19 @@ static int alx_validate_mac_addr(u8 *mac_addr)
 {
 	int retval = 0;
 
-	if (mac_addr[0] & 0x01) {
-		printk(KERN_DEBUG "MAC address is multicast\n");
+	if (is_broadcast_ether_addr(mac_addr)) {
+		pr_debug("MAC address is broadcast\n");
 		retval = -EADDRNOTAVAIL;
-	} else if (mac_addr[0] == 0xff && mac_addr[1] == 0xff) {
-		printk(KERN_DEBUG "MAC address is broadcast\n");
+	} else if (is_multicast_ether_addr(mac_addr)) {
+		pr_debug("MAC address is multicast\n");
 		retval = -EADDRNOTAVAIL;
-	} else if (mac_addr[0] == 0 && mac_addr[1] == 0 &&
-		   mac_addr[2] == 0 && mac_addr[3] == 0 &&
-		   mac_addr[4] == 0 && mac_addr[5] == 0) {
-		printk(KERN_DEBUG "MAC address is all zeros\n");
+	} else if (is_zero_ether_addr(mac_addr)) {
+		pr_debug("MAC address is all zeros\n");
 		retval = -EADDRNOTAVAIL;
 	}
 	return retval;
 }
 
-
 /*
  *  alx_set_mac_type - Sets MAC type
  */
@@ -459,7 +455,7 @@ static bool alx_get_rrdesc(struct alx_rx_queue *rxque,
 
 	if (likely(srrd->genr.nor != 1)) {
 		/* TODO support mul rfd*/
-		printk(KERN_EMERG "Multi rfd not support yet!\n");
+		pr_emerg("Multi rfd not support yet!\n");
 	}
 
 	srrd->genr.update = 0;
@@ -1068,7 +1064,7 @@ static void alx_set_msix_flags(struct alx_msix_param *msix,
 			SET_MSIX_FLAG(RX7);
 			break;
 		default:
-			printk(KERN_ERR "alx_set_msix_flags: rx error.");
+			pr_err("%s: rx error\n", __func__);
 			break;
 		}
 	} else if (type == alx_msix_type_tx) {
@@ -1086,7 +1082,7 @@ static void alx_set_msix_flags(struct alx_msix_param *msix,
 			SET_MSIX_FLAG(TX3);
 			break;
 		default:
-			printk(KERN_ERR "alx_set_msix_flags: tx error.");
+			pr_err("%s: tx error\n", __func__);
 			break;
 		}
 	} else if (type == alx_msix_type_other) {
@@ -1104,7 +1100,7 @@ static void alx_set_msix_flags(struct alx_msix_param *msix,
 			SET_MSIX_FLAG(PHY);
 			break;
 		default:
-			printk(KERN_ERR "alx_set_msix_flags: other error.");
+			pr_err("%s: other error\n", __func__);
 			break;
 		}
 	}
@@ -1742,11 +1738,11 @@ static int alx_alloc_all_rtx_queue(struct alx_adapter *adpt)
 	return 0;
 
 err_alloc_rx_queue:
-	alx_err(adpt, "goto err_alloc_rx_queue");
+	alx_err(adpt, "goto err_alloc_rx_queue\n");
 	for (que_idx = 0; que_idx < adpt->num_rxques; que_idx++)
 		kfree(adpt->rx_queue[que_idx]);
 err_alloc_tx_queue:
-	alx_err(adpt, "goto err_alloc_tx_queue");
+	alx_err(adpt, "goto err_alloc_tx_queue\n");
 	for (que_idx = 0; que_idx < adpt->num_txques; que_idx++)
 		kfree(adpt->tx_queue[que_idx]);
 	return -ENOMEM;
@@ -2976,17 +2972,17 @@ static void alx_link_task_routine(struct alx_adapter *adpt)
 		if (netif_carrier_ok(netdev))
 			return;
 
-		link_desc = (hw->link_speed == ALX_LINK_SPEED_1GB_FULL) ?
+		link_desc = hw->link_speed == ALX_LINK_SPEED_1GB_FULL) ?
 			"1 Gbps Duplex Full" :
-			(hw->link_speed == ALX_LINK_SPEED_100_FULL ?
-			 "100 Mbps Duplex Full" :
-			 (hw->link_speed == ALX_LINK_SPEED_100_HALF ?
-			  "100 Mbps Duplex Half" :
-			  (hw->link_speed == ALX_LINK_SPEED_10_FULL ?
-			   "10 Mbps Duplex Full" :
-			   (hw->link_speed == ALX_LINK_SPEED_10_HALF ?
-			    "10 Mbps Duplex HALF" :
-			    "unknown speed"))));
+			hw->link_speed == ALX_LINK_SPEED_100_FULL ?
+			"100 Mbps Duplex Full" :
+			hw->link_speed == ALX_LINK_SPEED_100_HALF ?
+			"100 Mbps Duplex Half" :
+			hw->link_speed == ALX_LINK_SPEED_10_FULL ?
+			"10 Mbps Duplex Full" :
+			hw->link_speed == ALX_LINK_SPEED_10_HALF ?
+			"10 Mbps Duplex HALF" :
+			"unknown speed");
 		netif_info(adpt, timer, adpt->netdev,
 			   "NIC Link is Up %s\n", link_desc);
 
@@ -3171,8 +3167,7 @@ do_csum:
 		cso = skb_checksum_start_offset(skb);
 
 		if (unlikely(cso & 0x1)) {
-			dev_err(&pdev->dev, "pay load offset should not be an "
-				"event number\n");
+			dev_err(&pdev->dev, "pay load offset should not be an event number\n");
 			return -1;
 		} else {
 			css = cso + skb->csum_offset;
@@ -3642,16 +3637,14 @@ static int __devinit alx_init(struct pci_dev *pdev,
 	alx_set_register_info_special(adpt);
 
 	netif_dbg(adpt, probe, adpt->netdev,
-		  "num_msix_noque_intrs = %d, num_msix_rxque_intrs = %d, "
-		  "num_msix_txque_intrs = %d\n",
+		  "num_msix_noque_intrs = %d, num_msix_rxque_intrs = %d, num_msix_txque_intrs = %d\n",
 		  adpt->num_msix_noques, adpt->num_msix_rxques,
 		  adpt->num_msix_txques);
 	netif_dbg(adpt, probe, adpt->netdev, "num_msix_all_intrs = %d\n",
 		  adpt->num_msix_intrs);
 
 	netif_dbg(adpt, probe, adpt->netdev,
-		  "RX Queue Count = %u, HRX Queue Count = %u, "
-		  "SRX Queue Count = %u, TX Queue Count = %u\n",
+		  "RX Queue Count = %u, HRX Queue Count = %u, SRX Queue Count = %u, TX Queue Count = %u\n",
 		  adpt->num_rxques, adpt->num_hw_rxques, adpt->num_sw_rxques,
 		  adpt->num_txques);
 
@@ -3719,7 +3712,7 @@ static int __devinit alx_init(struct pci_dev *pdev,
 			   CHK_ADPT_FLAG(0, SRSS_EN) ? "Enable" : "Disable");
 	}
 
-	printk(KERN_INFO "alx: Atheros Gigabit Network Connection\n");
+	pr_info("Atheros Gigabit Network Connection\n");
 	cards_found++;
 	return 0;
 
@@ -3882,7 +3875,7 @@ static int __init alx_init_module(void)
 {
 	int retval;
 
-	printk(KERN_INFO "%s\n", alx_drv_description);
+	pr_info("%s\n", alx_drv_description);
 	retval = pci_register_driver(&alx_driver);
 
 	return retval;
diff --git a/drivers/net/ethernet/atheros/alx/alx_sw.h b/drivers/net/ethernet/atheros/alx/alx_sw.h
index 3daa392..9118da5 100644
--- a/drivers/net/ethernet/atheros/alx/alx_sw.h
+++ b/drivers/net/ethernet/atheros/alx/alx_sw.h
@@ -479,8 +479,8 @@ extern int alc_init_hw_callbacks(struct alx_hw *hw);
 extern int alf_init_hw_callbacks(struct alx_hw *hw);
 
 /* Logging message functions */
-void __printf(3, 4) alx_hw_printk(const char *level, const struct alx_hw *hw,
-				  const char *fmt, ...);
+void __printf(3, 4)
+alx_hw_printk(const char *level, const struct alx_hw *hw, const char *fmt, ...);
 
 #define alx_hw_err(_hw, _format, ...) \
 	alx_hw_printk(KERN_ERR, _hw, _format, ##__VA_ARGS__)
