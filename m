From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/16] ixgb: Use generic MDIO definitions
Date: Wed, 29 Apr 2009 19:11:05 +0100
Message-ID: <1241028665.3246.49.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandenburg <jesse.brandeburg@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:59038 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759559AbZD2SLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:11:07 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ixgb/ixgb_hw.c |   20 ++++++++++----------
 drivers/net/ixgb/ixgb_hw.h |   14 ++------------
 2 files changed, 12 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 11dcda0..ff67a84 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -192,7 +192,7 @@ ixgb_identify_xpak_vendor(struct ixgb_hw *hw)
 		vendor_name[i] = ixgb_read_phy_reg(hw,
 						   MDIO_PMA_PMD_XPAK_VENDOR_NAME
 						   + i, IXGB_PHY_ADDRESS,
-						   MDIO_PMA_PMD_DID);
+						   MDIO_MMD_PMAPMD);
 	}
 
 	/* Determine the actual vendor */
@@ -1225,15 +1225,15 @@ ixgb_optics_reset(struct ixgb_hw *hw)
 		u16 mdio_reg;
 
 		ixgb_write_phy_reg(hw,
-					MDIO_PMA_PMD_CR1,
-					IXGB_PHY_ADDRESS,
-					MDIO_PMA_PMD_DID,
-					MDIO_PMA_PMD_CR1_RESET);
-
-		mdio_reg = ixgb_read_phy_reg( hw,
-						MDIO_PMA_PMD_CR1,
-						IXGB_PHY_ADDRESS,
-						MDIO_PMA_PMD_DID);
+				   MDIO_CTRL1,
+				   IXGB_PHY_ADDRESS,
+				   MDIO_MMD_PMAPMD,
+				   MDIO_CTRL1_RESET);
+
+		mdio_reg = ixgb_read_phy_reg(hw,
+					     MDIO_CTRL1,
+					     IXGB_PHY_ADDRESS,
+					     MDIO_MMD_PMAPMD);
 	}
 
 	return;
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index 831fe0c..af6ca3a 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -29,6 +29,8 @@
 #ifndef _IXGB_HW_H_
 #define _IXGB_HW_H_
 
+#include <linux/mdio.h>
+
 #include "ixgb_osdep.h"
 
 /* Enums */
@@ -507,18 +509,6 @@ typedef enum {
 /* Definitions for the optics devices on the MDIO bus. */
 #define IXGB_PHY_ADDRESS             0x0	/* Single PHY, multiple "Devices" */
 
-/* Standard five-bit Device IDs.  See IEEE 802.3ae, clause 45 */
-#define MDIO_PMA_PMD_DID        0x01
-#define MDIO_WIS_DID            0x02
-#define MDIO_PCS_DID            0x03
-#define MDIO_XGXS_DID           0x04
-
-/* Standard PMA/PMD registers and bit definitions. */
-/* Note: This is a very limited set of definitions,      */
-/* only implemented features are defined.                */
-#define MDIO_PMA_PMD_CR1        0x0000
-#define MDIO_PMA_PMD_CR1_RESET  0x8000
-
 #define MDIO_PMA_PMD_XPAK_VENDOR_NAME       0x803A	/* XPAK/XENPAK devices only */
 
 /* Vendor-specific MDIO registers */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

