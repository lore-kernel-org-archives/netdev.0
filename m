From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: dsa: bcm_sf2: Add VLAN registers definitions
Date: Thu,  9 Jun 2016 17:42:07 -0700
Message-ID: <1465519328-14249-4-git-send-email-f.fainelli@gmail.com>
References: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
	idosch@mellanox.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36848 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbcFJAmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 20:42:40 -0400
Received: by mail-pa0-f67.google.com with SMTP id fg1so3804930pad.3
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 17:42:40 -0700 (PDT)
In-Reply-To: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the definitions for the VLAN registers that we are going to
manipulate in subsequent patches.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2_regs.h | 70 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 70 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 97780d43b5c0..9f2a9cb42074 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -274,6 +274,23 @@
 #define CORE_ARLA_SRCH_RSLT_MACVID(x)	(CORE_ARLA_SRCH_RSLT_0_MACVID + ((x) * 0x40))
 #define CORE_ARLA_SRCH_RSLT(x)		(CORE_ARLA_SRCH_RSLT_0 + ((x) * 0x40))
 
+#define CORE_ARLA_VTBL_RWCTRL		0x1600
+#define  ARLA_VTBL_CMD_WRITE		0
+#define  ARLA_VTBL_CMD_READ		1
+#define  ARLA_VTBL_CMD_CLEAR		2
+#define  ARLA_VTBL_STDN			(1 << 7)
+
+#define CORE_ARLA_VTBL_ADDR		0x1604
+#define  VTBL_ADDR_INDEX_MASK		0xfff
+
+#define CORE_ARLA_VTBL_ENTRY		0x160c
+#define  FWD_MAP_MASK			0x1ff
+#define  UNTAG_MAP_MASK			0x1ff
+#define  UNTAG_MAP_SHIFT		9
+#define  MSTP_INDEX_MASK		0x7
+#define  MSTP_INDEX_SHIFT		18
+#define  FWD_MODE			(1 << 21)
+
 #define CORE_MEM_PSM_VDD_CTRL		0x2380
 #define  P_TXQ_PSM_VDD_SHIFT		2
 #define  P_TXQ_PSM_VDD_MASK		0x3
@@ -287,6 +304,59 @@
 #define CORE_PORT_VLAN_CTL_PORT(x)	(0xc400 + ((x) * 0x8))
 #define  PORT_VLAN_CTRL_MASK		0x1ff
 
+#define CORE_VLAN_CTRL0			0xd000
+#define  CHANGE_1P_VID_INNER		(1 << 0)
+#define  CHANGE_1P_VID_OUTER		(1 << 1)
+#define  CHANGE_1Q_VID			(1 << 3)
+#define  VLAN_LEARN_MODE_SVL		(0 << 5)
+#define  VLAN_LEARN_MODE_IVL		(3 << 5)
+#define  VLAN_EN			(1 << 7)
+
+#define CORE_VLAN_CTRL1			0xd004
+#define  EN_RSV_MCAST_FWDMAP		(1 << 2)
+#define  EN_RSV_MCAST_UNTAG		(1 << 3)
+#define  EN_IPMC_BYPASS_FWDMAP		(1 << 5)
+#define  EN_IPMC_BYPASS_UNTAG		(1 << 6)
+
+#define CORE_VLAN_CTRL2			0xd008
+#define  EN_MIIM_BYPASS_V_FWDMAP	(1 << 2)
+#define  EN_GMRP_GVRP_V_FWDMAP		(1 << 5)
+#define  EN_GMRP_GVRP_UNTAG_MAP		(1 << 6)
+
+#define CORE_VLAN_CTRL3			0xd00c
+#define  EN_DROP_NON1Q_MASK		0x1ff
+
+#define CORE_VLAN_CTRL4			0xd014
+#define  RESV_MCAST_FLOOD		(1 << 1)
+#define  EN_DOUBLE_TAG_MASK		0x3
+#define  EN_DOUBLE_TAG_SHIFT		2
+#define  EN_MGE_REV_GMRP		(1 << 4)
+#define  EN_MGE_REV_GVRP		(1 << 5)
+#define  INGR_VID_CHK_SHIFT		6
+#define  INGR_VID_CHK_MASK		0x3
+#define  INGR_VID_CHK_FWD		(0 << INGR_VID_CHK_SHIFT)
+#define  INGR_VID_CHK_DROP		(1 << INGR_VID_CHK_SHIFT)
+#define  INGR_VID_CHK_NO_CHK		(2 << INGR_VID_CHK_SHIFT)
+#define  INGR_VID_CHK_VID_VIOL_IMP	(3 << INGR_VID_CHK_SHIFT)
+
+#define CORE_VLAN_CTRL5			0xd018
+#define  EN_CPU_RX_BYP_INNER_CRCCHCK	(1 << 0)
+#define  EN_VID_FFF_FWD			(1 << 2)
+#define  DROP_VTABLE_MISS		(1 << 3)
+#define  EGRESS_DIR_FRM_BYP_TRUNK_EN	(1 << 4)
+#define  PRESV_NON1Q			(1 << 6)
+
+#define CORE_VLAN_CTRL6			0xd01c
+#define  STRICT_SFD_DETECT		(1 << 0)
+#define  DIS_ARL_BUST_LMIT		(1 << 4)
+
+#define CORE_DEFAULT_1Q_TAG_P(x)	(0xd040 + ((x) * 8))
+#define  CFI_SHIFT			12
+#define  PRI_SHIFT			13
+#define  PRI_MASK			0x7
+
+#define CORE_JOIN_ALL_VLAN_EN		0xd140
+
 #define CORE_EEE_EN_CTRL		0x24800
 #define CORE_EEE_LPI_INDICATE		0x24810
 
-- 
2.7.4
