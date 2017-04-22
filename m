From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 3/5] bnxt_en: Add 100G link speed reporting for BCM57454 ASIC in ethtool
Date: Fri, 21 Apr 2017 20:11:24 -0400
Message-ID: <1492819886-19625-4-git-send-email-michael.chan@broadcom.com>
References: <1492819886-19625-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:35740 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162642AbdDVALm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 20:11:42 -0400
Received: by mail-wr0-f181.google.com with SMTP id z52so21365472wrc.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 17:11:41 -0700 (PDT)
In-Reply-To: <1492819886-19625-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Khungar <deepak.khungar@broadcom.com>

Added support for 100G link speed reporting for Broadcom BCM57454
ASIC in ethtool command.

Signed-off-by: Deepak Khungar <deepak.khungar@broadcom.com>
Signed-off-by: Ray Jui <ray.jui@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  5 +++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  2 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 14 +++++++++++++-
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 129b810..447ee3d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5471,7 +5471,8 @@ static void bnxt_report_link(struct bnxt *bp)
 	if (bp->link_info.link_up) {
 		const char *duplex;
 		const char *flow_ctrl;
-		u16 speed, fec;
+		u32 speed;
+		u16 fec;
 
 		netif_carrier_on(bp->dev);
 		if (bp->link_info.duplex == BNXT_LINK_DUPLEX_FULL)
@@ -5487,7 +5488,7 @@ static void bnxt_report_link(struct bnxt *bp)
 		else
 			flow_ctrl = "none";
 		speed = bnxt_fw_to_ethtool_speed(bp->link_info.link_speed);
-		netdev_info(bp->dev, "NIC Link is Up, %d Mbps %s duplex, Flow control: %s\n",
+		netdev_info(bp->dev, "NIC Link is Up, %u Mbps %s duplex, Flow control: %s\n",
 			    speed, duplex, flow_ctrl);
 		if (bp->flags & BNXT_FLAG_EEE_CAP)
 			netdev_info(bp->dev, "EEE is %s\n",
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index c9a1688..25fef61 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -851,6 +851,7 @@ struct bnxt_link_info {
 #define BNXT_LINK_SPEED_25GB	PORT_PHY_QCFG_RESP_LINK_SPEED_25GB
 #define BNXT_LINK_SPEED_40GB	PORT_PHY_QCFG_RESP_LINK_SPEED_40GB
 #define BNXT_LINK_SPEED_50GB	PORT_PHY_QCFG_RESP_LINK_SPEED_50GB
+#define BNXT_LINK_SPEED_100GB	PORT_PHY_QCFG_RESP_LINK_SPEED_100GB
 	u16			support_speeds;
 	u16			auto_link_speeds;	/* fw adv setting */
 #define BNXT_LINK_SPEED_MSK_100MB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_100MB
@@ -862,6 +863,7 @@ struct bnxt_link_info {
 #define BNXT_LINK_SPEED_MSK_25GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_25GB
 #define BNXT_LINK_SPEED_MSK_40GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_40GB
 #define BNXT_LINK_SPEED_MSK_50GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_50GB
+#define BNXT_LINK_SPEED_MSK_100GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_100GB
 	u16			support_auto_speeds;
 	u16			lp_auto_link_speeds;
 	u16			force_link_speed;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 848ecf2..11ddf0a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -929,6 +929,9 @@ u32 _bnxt_fw_to_ethtool_adv_spds(u16 fw_speeds, u8 fw_pause)
 	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_50GB)			\
 		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
 						     50000baseCR2_Full);\
+	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_100GB)			\
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
+						     100000baseCR4_Full);\
 	if ((fw_pause) & BNXT_LINK_PAUSE_RX) {				\
 		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
 						     Pause);		\
@@ -965,6 +968,9 @@ u32 _bnxt_fw_to_ethtool_adv_spds(u16 fw_speeds, u8 fw_pause)
 	if (ethtool_link_ksettings_test_link_mode(lk_ksettings, name,	\
 						  50000baseCR2_Full))	\
 		(fw_speeds) |= BNXT_LINK_SPEED_MSK_50GB;		\
+	if (ethtool_link_ksettings_test_link_mode(lk_ksettings, name,	\
+						  100000baseCR4_Full))	\
+		(fw_speeds) |= BNXT_LINK_SPEED_MSK_100GB;		\
 }
 
 static void bnxt_fw_to_ethtool_advertised_spds(struct bnxt_link_info *link_info,
@@ -1027,6 +1033,8 @@ u32 bnxt_fw_to_ethtool_speed(u16 fw_link_speed)
 		return SPEED_40000;
 	case BNXT_LINK_SPEED_50GB:
 		return SPEED_50000;
+	case BNXT_LINK_SPEED_100GB:
+		return SPEED_100000;
 	default:
 		return SPEED_UNKNOWN;
 	}
@@ -1092,7 +1100,7 @@ static int bnxt_get_link_ksettings(struct net_device *dev,
 	return 0;
 }
 
-static u32 bnxt_get_fw_speed(struct net_device *dev, u16 ethtool_speed)
+static u32 bnxt_get_fw_speed(struct net_device *dev, u32 ethtool_speed)
 {
 	struct bnxt *bp = netdev_priv(dev);
 	struct bnxt_link_info *link_info = &bp->link_info;
@@ -1132,6 +1140,10 @@ static u32 bnxt_get_fw_speed(struct net_device *dev, u16 ethtool_speed)
 		if (support_spds & BNXT_LINK_SPEED_MSK_50GB)
 			fw_speed = PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_50GB;
 		break;
+	case SPEED_100000:
+		if (support_spds & BNXT_LINK_SPEED_MSK_100GB)
+			fw_speed = PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_100GB;
+		break;
 	default:
 		netdev_err(dev, "unsupported speed!\n");
 		break;
-- 
1.8.3.1
