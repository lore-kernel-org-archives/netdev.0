From: Joe Perches <joe@perches.com>
Subject: [PATCH 6/9] s2io.c: convert printks to pr_<level>
Date: Mon, 24 Aug 2009 20:29:45 -0700
Message-ID: <8447fcff04cb998aba685033f605787876e8e41a.1251170438.git.joe@perches.com>
References: <cover.1251170438.git.joe@perches.com>
Cc: Anil Murthy <anil.murthy@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1360 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754352AbZHYDjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2009 23:39:06 -0400
In-Reply-To: <cover.1251170438.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed trivial typo as well

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/s2io.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 003dd8c..2805edd 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -54,6 +54,8 @@
  *      Possible values '1' for enable and '0' for disable. Default is '0'
  ************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/errno.h>
@@ -5547,8 +5549,7 @@ static int s2io_ethtool_idnic(struct net_device *dev, u32 data)
 	if ((sp->device_type == XFRAME_I_DEVICE) && ((subid & 0xFF) < 0x07)) {
 		val64 = readq(&bar0->adapter_control);
 		if (!(val64 & ADAPTER_CNTL_EN)) {
-			printk(KERN_ERR
-			       "Adapter Link down, cannot blink LED\n");
+			pr_err("Adapter Link down, cannot blink LED\n");
 			return -EFAULT;
 		}
 	}
@@ -7130,8 +7131,7 @@ static int s2io_add_isr(struct s2io_nic *sp)
 			}
 		}
 		if (!err) {
-			printk(KERN_INFO "MSI-X-RX %d entries enabled\n",
-			       --msix_rx_cnt);
+			pr_info("MSI-X-RX %d entries enabled\n", --msix_rx_cnt);
 			DBG_PRINT(INFO_DBG, "MSI-X-TX entries enabled"
 				  " through alarm vector\n");
 		}
@@ -8724,8 +8724,7 @@ static pci_ers_result_t s2io_io_slot_reset(struct pci_dev *pdev)
 	struct s2io_nic *sp = netdev_priv(netdev);
 
 	if (pci_enable_device(pdev)) {
-		printk(KERN_ERR "s2io: "
-		       "Cannot re-enable PCI device after reset.\n");
+		pr_err("Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 
@@ -8749,15 +8748,13 @@ static void s2io_io_resume(struct pci_dev *pdev)
 
 	if (netif_running(netdev)) {
 		if (s2io_card_up(sp)) {
-			printk(KERN_ERR "s2io: "
-			       "Can't bring device back up after reset.\n");
+			pr_err("Can't bring device back up after reset.\n");
 			return;
 		}
 
 		if (s2io_set_mac_addr(netdev, netdev->dev_addr) == FAILURE) {
 			s2io_card_down(sp);
-			printk(KERN_ERR "s2io: "
-			       "Can't resetore mac addr after reset.\n");
+			pr_err("Can't restore mac addr after reset.\n");
 			return;
 		}
 	}
-- 
1.6.3.1.10.g659a0.dirty

