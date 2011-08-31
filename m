From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 8/8] tg3: Code movement
Date: Wed, 31 Aug 2011 14:44:54 -0700
Message-ID: <1314827094-29714-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2589 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932173Ab1HaRzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 13:55:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch just moves some code around for better organization.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 88426b2..8caadc2 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3819,6 +3819,7 @@ static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
 		if (tg3_ctrl != all_mask)
 			return 0;
 	}
+
 	return 1;
 }
 
@@ -4119,8 +4120,8 @@ relink:
 			newlnkctl = oldlnkctl | PCI_EXP_LNKCTL_CLKREQ_EN;
 		if (newlnkctl != oldlnkctl)
 			pci_write_config_word(tp->pdev,
-					      pci_pcie_cap(tp->pdev) + PCI_EXP_LNKCTL,
-					      newlnkctl);
+					      pci_pcie_cap(tp->pdev) +
+					      PCI_EXP_LNKCTL, newlnkctl);
 	}
 
 	if (current_link_up != netif_carrier_ok(tp->dev)) {
@@ -6733,6 +6734,10 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
+	if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&
+	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
+		base_flags |= TXD_FLAG_JMB_PKT;
+
 #ifdef BCM_KERNEL_SUPPORTS_8021Q
 	if (vlan_tx_tag_present(skb)) {
 		base_flags |= TXD_FLAG_VLAN;
@@ -6740,10 +6745,6 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 #endif
 
-	if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&
-	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
-		base_flags |= TXD_FLAG_JMB_PKT;
-
 	len = skb_headlen(skb);
 
 	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
@@ -14081,7 +14082,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		/* BCM5785 devices are effectively PCIe devices, and should
 		 * follow PCIe codepaths, but do not have a PCIe capabilities
 		 * section.
-		*/
+		 */
 		tg3_flag_set(tp, PCI_EXPRESS);
 	} else if (!tg3_flag(tp, 5705_PLUS) ||
 		   tg3_flag(tp, 5780_CLASS)) {
@@ -15541,7 +15542,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		tnapi->tx_pending = TG3_DEF_TX_RING_PENDING;
 
 		tnapi->int_mbox = intmbx;
-		if (i < 4)
+		if (i <= 4)
 			intmbx += 0x8;
 		else
 			intmbx += 0x4;
-- 
1.7.3.4
