From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 11/13] ixgb: Add CX4 PHY type detection and subdevice ID.
Date: Wed, 16 Aug 2006 14:56:40 -0700
Message-ID: <20060816215640.27080.24384.stgit@gitlost.site>
References: <20060816215336.27080.56147.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:778 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932261AbWHPVsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:48:51 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060816215336.27080.56147.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Manasi Deval <manasi.deval@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_hw.c  |   11 +++++++++++
 drivers/net/ixgb/ixgb_ids.h |    1 +
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index f7fa10e..2b15155 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -236,6 +236,17 @@ ixgb_identify_phy(struct ixgb_hw *hw)
 		DEBUGOUT("Identified G6104 optics\n");
 		phy_type = ixgb_phy_type_g6104;
 		break;
+	case IXGB_DEVICE_ID_82597EX_CX4:
+		DEBUGOUT("Identified CX4\n");
+		xpak_vendor = ixgb_identify_xpak_vendor(hw);
+		if (xpak_vendor == ixgb_xpak_vendor_intel) {
+			DEBUGOUT("Identified TXN17201 optics\n");
+			phy_type = ixgb_phy_type_txn17201;
+		} else {
+			DEBUGOUT("Identified G6005 optics\n");
+			phy_type = ixgb_phy_type_g6005;
+		}
+		break;
 	default:
 		DEBUGOUT("Unknown physical layer module\n");
 		phy_type = ixgb_phy_type_unknown;
diff --git a/drivers/net/ixgb/ixgb_ids.h b/drivers/net/ixgb/ixgb_ids.h
index 40a085f..9fd6118 100644
--- a/drivers/net/ixgb/ixgb_ids.h
+++ b/drivers/net/ixgb/ixgb_ids.h
@@ -45,6 +45,7 @@
 
 #define IXGB_DEVICE_ID_82597EX_CX4   0x109E
 #define IXGB_SUBDEVICE_ID_A00C  0xA00C
+#define IXGB_SUBDEVICE_ID_A01C  0xA01C
 
 #endif /* #ifndef _IXGB_IDS_H_ */
 /* End of File */



--
Auke Kok <auke-jan.h.kok@intel.com>
