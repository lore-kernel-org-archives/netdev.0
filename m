From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 03/13] driver: atm: remove unnecessary skb NULL check before calling dev_kfree_skb_irq
Date: Sat,  2 Nov 2013 19:17:44 +0530
Message-ID: <1383400074-30555-4-git-send-email-govindarajulu90@gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_kfree_skb_irq is protected from NULL. No need to check for NULL while
calling this function.

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 drivers/atm/eni.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index b1955ba..78a4445 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -481,7 +481,7 @@ trouble:
 	if (paddr)
 		pci_unmap_single(eni_dev->pci_dev,paddr,skb->len,
 		    PCI_DMA_FROMDEVICE);
-	if (skb) dev_kfree_skb_irq(skb);
+	dev_kfree_skb_irq(skb);
 	return -1;
 }
 
-- 
1.8.4.2
