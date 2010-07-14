From: Christoph Egger <siccegge@cs.fau.de>
Subject: [PATCH 06/11] Removing dead CHELSIO_T1_COUGAR
Date: Wed, 14 Jul 2010 14:41:04 +0200
Message-ID: <f46378f51fe7128f755f6cb324a85e958106e3be.1279110895.git.siccegge@cs.fau.de>
References: <cover.1279110894.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vamos-dev@i4.informatik.uni-erlangen.de
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1279110894.git.siccegge@cs.fau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CHELSIO_T1_COUGAR doesn't exist in Kconfig, therefore removing all
references for it from the source code.

Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
---
 drivers/net/chelsio/subr.c |   48 +------------------------------------------
 1 files changed, 2 insertions(+), 46 deletions(-)

diff --git a/drivers/net/chelsio/subr.c b/drivers/net/chelsio/subr.c
index 53bde15..8ff621e 100644
--- a/drivers/net/chelsio/subr.c
+++ b/drivers/net/chelsio/subr.c
@@ -185,9 +185,6 @@ static int t1_pci_intr_handler(adapter_t *adapter)
 	return 0;
 }
 
-#ifdef CONFIG_CHELSIO_T1_COUGAR
-#include "cspi.h"
-#endif
 #ifdef CONFIG_CHELSIO_T1_1G
 #include "fpga_defs.h"
 
@@ -280,7 +277,7 @@ static void mi1_mdio_init(adapter_t *adapter, const struct board_info *bi)
 	t1_tpi_write(adapter, A_ELMER0_PORT0_MI1_CFG, val);
 }
 
-#if defined(CONFIG_CHELSIO_T1_1G) || defined(CONFIG_CHELSIO_T1_COUGAR)
+#if defined(CONFIG_CHELSIO_T1_1G)
 /*
  * Elmer MI1 MDIO read/write operations.
  */
@@ -317,7 +314,7 @@ static int mi1_mdio_write(struct net_device *dev, int phy_addr, int mmd_addr,
 	return 0;
 }
 
-#if defined(CONFIG_CHELSIO_T1_1G) || defined(CONFIG_CHELSIO_T1_COUGAR)
+#if defined(CONFIG_CHELSIO_T1_1G)
 static const struct mdio_ops mi1_mdio_ops = {
 	.init = mi1_mdio_init,
 	.read = mi1_mdio_read,
@@ -752,31 +749,6 @@ int t1_elmer0_ext_intr_handler(adapter_t *adapter)
 					 mod_detect ? "removed" : "inserted");
 		}
 		break;
-#ifdef CONFIG_CHELSIO_T1_COUGAR
-	case CHBT_BOARD_COUGAR:
-		if (adapter->params.nports == 1) {
-			if (cause & ELMER0_GP_BIT1) {         /* Vitesse MAC */
-				struct cmac *mac = adapter->port[0].mac;
-				mac->ops->interrupt_handler(mac);
-			}
-			if (cause & ELMER0_GP_BIT5) {     /* XPAK MOD_DETECT */
-			}
-		} else {
-			int i, port_bit;
-
-			for_each_port(adapter, i) {
-				port_bit = i ? i + 1 : 0;
-				if (!(cause & (1 << port_bit)))
-					continue;
-
-				phy = adapter->port[i].phy;
-				phy_cause = phy->ops->interrupt_handler(phy);
-				if (phy_cause & cphy_cause_link_change)
-					t1_link_changed(adapter, i);
-			}
-		}
-		break;
-#endif
 	}
 	t1_tpi_write(adapter, A_ELMER0_INT_CAUSE, cause);
 	return 0;
@@ -1004,10 +976,6 @@ int t1_init_hw_modules(adapter_t *adapter)
 		       adapter->regs + A_MC5_CONFIG);
 	}
 
-#ifdef CONFIG_CHELSIO_T1_COUGAR
-	if (adapter->cspi && t1_cspi_init(adapter->cspi))
-		goto out_err;
-#endif
 	if (adapter->espi && t1_espi_init(adapter->espi, bi->chip_mac,
 					  bi->espi_nports))
 		goto out_err;
@@ -1061,10 +1029,6 @@ void t1_free_sw_modules(adapter_t *adapter)
 		t1_tp_destroy(adapter->tp);
 	if (adapter->espi)
 		t1_espi_destroy(adapter->espi);
-#ifdef CONFIG_CHELSIO_T1_COUGAR
-	if (adapter->cspi)
-		t1_cspi_destroy(adapter->cspi);
-#endif
 }
 
 static void __devinit init_link_config(struct link_config *lc,
@@ -1084,14 +1048,6 @@ static void __devinit init_link_config(struct link_config *lc,
 	}
 }
 
-#ifdef CONFIG_CHELSIO_T1_COUGAR
-	if (bi->clock_cspi && !(adapter->cspi = t1_cspi_create(adapter))) {
-		pr_err("%s: CSPI initialization failed\n",
-		       adapter->name);
-		goto error;
-	}
-#endif
-
 /*
  * Allocate and initialize the data structures that hold the SW state of
  * the Terminator HW modules.
-- 
1.7.0.4
