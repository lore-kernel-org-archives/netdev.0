From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH] isdn: hardware: mISDN: Remove reference to CONFIG_8xx
Date: Thu, 16 Mar 2017 10:18:02 +0100 (CET)
Message-ID: <20170316091802.E463D68481@localhost.localdomain>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CONFIG_8xx is deprecated and should soon be removed in favor
of CONFIG_PPC_8xx.
Anyway, hfc_multi_8xx.h only uses 8xx I/O ports which are
linked to the CPM1 communication processor included in the 8xx
rather than the 8xx itself.

This patch therefore makes it dependent on CONFIG_CPM1 instead,
like several other drivers.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 drivers/isdn/hardware/mISDN/Kconfig         | 6 +++---
 drivers/isdn/hardware/mISDN/hfc_multi_8xx.h | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/Kconfig b/drivers/isdn/hardware/mISDN/Kconfig
index 09df54fc1fef..fda912b0833f 100644
--- a/drivers/isdn/hardware/mISDN/Kconfig
+++ b/drivers/isdn/hardware/mISDN/Kconfig
@@ -13,7 +13,7 @@ config MISDN_HFCPCI
 
 config MISDN_HFCMULTI
 	tristate "Support for HFC multiport cards (HFC-4S/8S/E1)"
-	depends on PCI || 8xx
+	depends on PCI || CPM1
 	depends on MISDN
 	help
 	  Enable support for cards with Cologne Chip AG's HFC multiport
@@ -27,8 +27,8 @@ config MISDN_HFCMULTI_8xx
 	bool "Support for XHFC embedded board in HFC multiport driver"
 	depends on MISDN
 	depends on MISDN_HFCMULTI
-	depends on 8xx
-	default 8xx
+	depends on CPM1
+	default CPM1
 	help
 	  Enable support for the XHFC embedded solution from Speech Design.
 
diff --git a/drivers/isdn/hardware/mISDN/hfc_multi_8xx.h b/drivers/isdn/hardware/mISDN/hfc_multi_8xx.h
index 0eafe9f04fca..8a254747768e 100644
--- a/drivers/isdn/hardware/mISDN/hfc_multi_8xx.h
+++ b/drivers/isdn/hardware/mISDN/hfc_multi_8xx.h
@@ -6,7 +6,7 @@
  *
  */
 
-#include <asm/8xx_immap.h>
+#include <asm/cpm1.h>
 
 /* Change this to the value used by your board */
 #ifndef IMAP_ADDR
-- 
2.12.0
