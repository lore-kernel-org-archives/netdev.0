From: ddaney.cavm@gmail.com
Subject: [PATCH 2/3] MIPS: Octeon: Update bootloader board type constants.
Date: Thu, 10 Nov 2011 16:29:46 -0800
Message-ID: <1320971387-29343-3-git-send-email-ddaney.cavm@gmail.com>
References: <1320971387-29343-1-git-send-email-ddaney.cavm@gmail.com>
Cc: David Daney <david.daney@cavium.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de, devel@driverdev.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:64982 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755662Ab1KKA3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 19:29:54 -0500
Received: by yenr9 with SMTP id r9so2595276yen.19
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 16:29:53 -0800 (PST)
In-Reply-To: <1320971387-29343-1-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>

Many new types of boards exist, so lets recognize them.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 .../cavium-octeon/executive/cvmx-helper-board.c    |   20 ++++++
 arch/mips/include/asm/octeon/cvmx-bootinfo.h       |   72 +++++++++++++++++++-
 arch/mips/include/asm/octeon/cvmx-helper-board.h   |    6 ++
 3 files changed, 95 insertions(+), 3 deletions(-)

diff --git a/arch/mips/cavium-octeon/executive/cvmx-helper-board.c b/arch/mips/cavium-octeon/executive/cvmx-helper-board.c
index 71590a3..fd20153 100644
--- a/arch/mips/cavium-octeon/executive/cvmx-helper-board.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper-board.c
@@ -117,6 +117,10 @@ int cvmx_helper_board_get_mii_address(int ipd_port)
 	case CVMX_BOARD_TYPE_EBH5200:
 	case CVMX_BOARD_TYPE_EBH5201:
 	case CVMX_BOARD_TYPE_EBT5200:
+		/* Board has 2 management ports */
+		if ((ipd_port >= CVMX_HELPER_BOARD_MGMT_IPD_PORT) &&
+		    (ipd_port < (CVMX_HELPER_BOARD_MGMT_IPD_PORT + 2)))
+			return ipd_port - CVMX_HELPER_BOARD_MGMT_IPD_PORT;
 		/*
 		 * Board has 4 SGMII ports. The PHYs start right after the MII
 		 * ports MII0 = 0, MII1 = 1, SGMII = 2-5.
@@ -128,6 +132,9 @@ int cvmx_helper_board_get_mii_address(int ipd_port)
 	case CVMX_BOARD_TYPE_EBH5600:
 	case CVMX_BOARD_TYPE_EBH5601:
 	case CVMX_BOARD_TYPE_EBH5610:
+		/* Board has 1 management port */
+		if (ipd_port == CVMX_HELPER_BOARD_MGMT_IPD_PORT)
+			return 0;
 		/*
 		 * Board has 8 SGMII ports. 4 connect out, two connect
 		 * to a switch, and 2 loop to each other
@@ -147,6 +154,19 @@ int cvmx_helper_board_get_mii_address(int ipd_port)
 			return ipd_port - 16 + 1;
 		else
 			return -1;
+	case CVMX_BOARD_TYPE_NIC_XLE_10G:
+	case CVMX_BOARD_TYPE_NIC10E:
+		return -1;
+	case CVMX_BOARD_TYPE_NIC4E:
+		if (ipd_port >= 0 && ipd_port <= 3)
+			return (ipd_port + 0x1f) & 0x1f;
+		else
+			return -1;
+	case CVMX_BOARD_TYPE_NIC2E:
+		if (ipd_port >= 0 && ipd_port <= 1)
+			return ipd_port + 1;
+		else
+			return -1;
 	case CVMX_BOARD_TYPE_BBGW_REF:
 		/*
 		 * No PHYs are connected to Octeon, everything is
diff --git a/arch/mips/include/asm/octeon/cvmx-bootinfo.h b/arch/mips/include/asm/octeon/cvmx-bootinfo.h
index d9d1668..1db1dc2 100644
--- a/arch/mips/include/asm/octeon/cvmx-bootinfo.h
+++ b/arch/mips/include/asm/octeon/cvmx-bootinfo.h
@@ -170,6 +170,22 @@ enum cvmx_board_types_enum {
 	/* Special 'generic' board type, supports many boards */
 	CVMX_BOARD_TYPE_GENERIC = 28,
 	CVMX_BOARD_TYPE_EBH5610 = 29,
+	CVMX_BOARD_TYPE_LANAI2_A = 30,
+	CVMX_BOARD_TYPE_LANAI2_U = 31,
+	CVMX_BOARD_TYPE_EBB5600 = 32,
+	CVMX_BOARD_TYPE_EBB6300 = 33,
+	CVMX_BOARD_TYPE_NIC_XLE_10G = 34,
+	CVMX_BOARD_TYPE_LANAI2_G = 35,
+	CVMX_BOARD_TYPE_EBT5810 = 36,
+	CVMX_BOARD_TYPE_NIC10E = 37,
+	CVMX_BOARD_TYPE_EP6300C = 38,
+	CVMX_BOARD_TYPE_EBB6800 = 39,
+	CVMX_BOARD_TYPE_NIC4E = 40,
+	CVMX_BOARD_TYPE_NIC2E = 41,
+	CVMX_BOARD_TYPE_EBB6600 = 42,
+	CVMX_BOARD_TYPE_REDWING = 43,
+	CVMX_BOARD_TYPE_NIC68_4 = 44,
+	CVMX_BOARD_TYPE_NIC10E_66 = 45,
 	CVMX_BOARD_TYPE_MAX,
 
 	/*
@@ -187,6 +203,23 @@ enum cvmx_board_types_enum {
 	CVMX_BOARD_TYPE_CUST_NS0216 = 10002,
 	CVMX_BOARD_TYPE_CUST_NB5 = 10003,
 	CVMX_BOARD_TYPE_CUST_WMR500 = 10004,
+	CVMX_BOARD_TYPE_CUST_ITB101 = 10005,
+	CVMX_BOARD_TYPE_CUST_NTE102 = 10006,
+	CVMX_BOARD_TYPE_CUST_AGS103 = 10007,
+	CVMX_BOARD_TYPE_CUST_GST104 = 10008,
+	CVMX_BOARD_TYPE_CUST_GCT105 = 10009,
+	CVMX_BOARD_TYPE_CUST_AGS106 = 10010,
+	CVMX_BOARD_TYPE_CUST_SGM107 = 10011,
+	CVMX_BOARD_TYPE_CUST_GCT108 = 10012,
+	CVMX_BOARD_TYPE_CUST_AGS109 = 10013,
+	CVMX_BOARD_TYPE_CUST_GCT110 = 10014,
+	CVMX_BOARD_TYPE_CUST_L2_AIR_SENDER = 10015,
+	CVMX_BOARD_TYPE_CUST_L2_AIR_RECEIVER = 10016,
+	CVMX_BOARD_TYPE_CUST_L2_ACCTON2_TX = 10017,
+	CVMX_BOARD_TYPE_CUST_L2_ACCTON2_RX = 10018,
+	CVMX_BOARD_TYPE_CUST_L2_WSTRNSNIC_TX = 10019,
+	CVMX_BOARD_TYPE_CUST_L2_WSTRNSNIC_RX = 10020,
+	CVMX_BOARD_TYPE_CUST_L2_ZINWELL = 10021,
 	CVMX_BOARD_TYPE_CUST_DEFINED_MAX = 20000,
 
 	/*
@@ -247,6 +280,22 @@ static inline const char *cvmx_board_type_to_string(enum
 		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CB5200)
 		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_GENERIC)
 		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_EBH5610)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_LANAI2_A)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_LANAI2_U)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_EBB5600)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_EBB6300)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_NIC_XLE_10G)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_LANAI2_G)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_EBT5810)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_NIC10E)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_EP6300C)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_EBB6800)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_NIC4E)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_NIC2E)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_EBB6600)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_REDWING)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_NIC68_4)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_NIC10E_66)
 		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_MAX)
 
 			/* Customer boards listed here */
@@ -255,6 +304,23 @@ static inline const char *cvmx_board_type_to_string(enum
 		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_NS0216)
 		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_NB5)
 		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_WMR500)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_ITB101)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_NTE102)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_AGS103)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_GST104)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_GCT105)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_AGS106)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_SGM107)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_GCT108)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_AGS109)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_GCT110)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_L2_AIR_SENDER)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_L2_AIR_RECEIVER)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_L2_ACCTON2_TX)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_L2_ACCTON2_RX)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_L2_WSTRNSNIC_TX)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_L2_WSTRNSNIC_RX)
+		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_L2_ZINWELL)
 		ENUM_BRD_TYPE_CASE(CVMX_BOARD_TYPE_CUST_DEFINED_MAX)
 
 		    /* Customer private range */
@@ -271,9 +337,9 @@ static inline const char *cvmx_chip_type_to_string(enum
 {
 	switch (type) {
 		ENUM_CHIP_TYPE_CASE(CVMX_CHIP_TYPE_NULL)
-		    ENUM_CHIP_TYPE_CASE(CVMX_CHIP_SIM_TYPE_DEPRECATED)
-		    ENUM_CHIP_TYPE_CASE(CVMX_CHIP_TYPE_OCTEON_SAMPLE)
-		    ENUM_CHIP_TYPE_CASE(CVMX_CHIP_TYPE_MAX)
+		ENUM_CHIP_TYPE_CASE(CVMX_CHIP_SIM_TYPE_DEPRECATED)
+		ENUM_CHIP_TYPE_CASE(CVMX_CHIP_TYPE_OCTEON_SAMPLE)
+		ENUM_CHIP_TYPE_CASE(CVMX_CHIP_TYPE_MAX)
 	}
 	return "Unsupported Chip";
 }
diff --git a/arch/mips/include/asm/octeon/cvmx-helper-board.h b/arch/mips/include/asm/octeon/cvmx-helper-board.h
index b465bec..88527fa 100644
--- a/arch/mips/include/asm/octeon/cvmx-helper-board.h
+++ b/arch/mips/include/asm/octeon/cvmx-helper-board.h
@@ -44,6 +44,12 @@ typedef enum {
 	set_phy_link_flags_flow_control_mask = 0x3 << 1,	/* Mask for 2 bit wide flow control field */
 } cvmx_helper_board_set_phy_link_flags_types_t;
 
+/*
+ * Fake IPD port, the RGMII/MII interface may use different PHY, use
+ * this macro to return appropriate MIX address to read the PHY.
+ */
+#define CVMX_HELPER_BOARD_MGMT_IPD_PORT     -10
+
 /**
  * cvmx_override_board_link_get(int ipd_port) is a function
  * pointer. It is meant to allow customization of the process of
-- 
1.7.2.3
