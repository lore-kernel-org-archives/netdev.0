From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 10/13] driver: infiniband: remove unnecessary NULL check before dev_kfree_skb_any
Date: Sat,  2 Nov 2013 19:17:51 +0530
Message-ID: <1383400074-30555-11-git-send-email-govindarajulu90@gmail.com>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	IvDoorn@gmail.com, sbhatewara@vmware.com, samuel@sortiz.org,
	chas@cmf.nrl.navy.mil, roland@kernel.org, isdn@linux-pingi.de,
	jcliburn@gmail.com, benve@cisco.com, ssujith@cisco.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shahed.shaikh@qlogic.com, joe@perches.com, apw@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:58535 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076Ab3KBNtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 09:49:14 -0400
In-Reply-To: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_kfree_skb_any is protected from NULL. No need to check for NULL
while calling this function.

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 drivers/infiniband/hw/amso1100/c2.c | 6 ++----
 drivers/infiniband/hw/nes/nes_hw.c  | 3 +--
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/amso1100/c2.c b/drivers/infiniband/hw/amso1100/c2.c
index d53cf51..30c4d00 100644
--- a/drivers/infiniband/hw/amso1100/c2.c
+++ b/drivers/infiniband/hw/amso1100/c2.c
@@ -312,10 +312,8 @@ static inline int c2_tx_free(struct c2_dev *c2dev, struct c2_element *elem)
 	pci_unmap_single(c2dev->pcidev, elem->mapaddr, elem->maplen,
 			 PCI_DMA_TODEVICE);
 
-	if (elem->skb) {
-		dev_kfree_skb_any(elem->skb);
-		elem->skb = NULL;
-	}
+	dev_kfree_skb_any(elem->skb);
+	elem->skb = NULL;
 
 	return 0;
 }
diff --git a/drivers/infiniband/hw/nes/nes_hw.c b/drivers/infiniband/hw/nes/nes_hw.c
index 9020024..2275a8e 100644
--- a/drivers/infiniband/hw/nes/nes_hw.c
+++ b/drivers/infiniband/hw/nes/nes_hw.c
@@ -2856,8 +2856,7 @@ void nes_nic_ce_handler(struct nes_device *nesdev, struct nes_hw_nic_cq *cq)
 							break;
 					}
 				}
-				if (skb)
-					dev_kfree_skb_any(skb);
+				dev_kfree_skb_any(skb);
 				nesnic->sq_tail++;
 				nesnic->sq_tail &= nesnic->sq_size-1;
 				if (sq_cqes > 128) {
-- 
1.8.4.2
