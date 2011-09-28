From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH 3/3] net: sh_eth: move the asm/sh_eth.h to include/linux/
Date: Wed, 28 Sep 2011 16:49:12 +0900
Message-ID: <4E82D178.9020808@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>
To: davem@davemloft.net, Paul Mundt <lethal@linux-sh.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 This patch is for net-next.

 arch/sh/include/asm/sh_eth.h          |   25 -------------------------
 drivers/net/ethernet/renesas/sh_eth.c |    1 +
 drivers/net/ethernet/renesas/sh_eth.h |    8 --------
 include/linux/sh_eth.h                |   25 +++++++++++++++++++++++++
 4 files changed, 26 insertions(+), 33 deletions(-)
 delete mode 100644 arch/sh/include/asm/sh_eth.h
 create mode 100644 include/linux/sh_eth.h

diff --git a/arch/sh/include/asm/sh_eth.h b/arch/sh/include/asm/sh_eth.h
deleted file mode 100644
index 2076acf..0000000
--- a/arch/sh/include/asm/sh_eth.h
+++ /dev/null
@@ -1,25 +0,0 @@
-#ifndef __ASM_SH_ETH_H__
-#define __ASM_SH_ETH_H__
-
-#include <linux/phy.h>
-
-enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
-enum {
-	SH_ETH_REG_GIGABIT,
-	SH_ETH_REG_FAST_SH4,
-	SH_ETH_REG_FAST_SH3_SH2
-};
-
-struct sh_eth_plat_data {
-	int phy;
-	int edmac_endian;
-	int register_type;
-	phy_interface_t phy_interface;
-	void (*set_mdio_gate)(void *addr);
-
-	unsigned char mac_addr[6];
-	unsigned no_ether_link:1;
-	unsigned ether_link_active_low:1;
-};
-
-#endif
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 38ccda5..6aa0704 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -35,6 +35,7 @@
 #include <linux/pm_runtime.h>
 #include <linux/slab.h>
 #include <linux/ethtool.h>
+#include <linux/sh_eth.h>

 #include "sh_eth.h"

diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 78e586e..47877b1 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -23,14 +23,6 @@
 #ifndef __SH_ETH_H__
 #define __SH_ETH_H__

-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/spinlock.h>
-#include <linux/netdevice.h>
-#include <linux/phy.h>
-
-#include <asm/sh_eth.h>
-
 #define CARDNAME	"sh-eth"
 #define TX_TIMEOUT	(5*HZ)
 #define TX_RING_SIZE	64	/* Tx ring size */
diff --git a/include/linux/sh_eth.h b/include/linux/sh_eth.h
new file mode 100644
index 0000000..2076acf
--- /dev/null
+++ b/include/linux/sh_eth.h
@@ -0,0 +1,25 @@
+#ifndef __ASM_SH_ETH_H__
+#define __ASM_SH_ETH_H__
+
+#include <linux/phy.h>
+
+enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
+enum {
+	SH_ETH_REG_GIGABIT,
+	SH_ETH_REG_FAST_SH4,
+	SH_ETH_REG_FAST_SH3_SH2
+};
+
+struct sh_eth_plat_data {
+	int phy;
+	int edmac_endian;
+	int register_type;
+	phy_interface_t phy_interface;
+	void (*set_mdio_gate)(void *addr);
+
+	unsigned char mac_addr[6];
+	unsigned no_ether_link:1;
+	unsigned ether_link_active_low:1;
+};
+
+#endif
-- 
1.7.1

