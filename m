From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 04/12] be2net: add speed reporting for 20G-KR interface
Date: Fri, 19 Sep 2014 15:46:54 +0530
Message-ID: <1411121822-25842-5-git-send-email-sathya.perla@emulex.com>
References: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:52817 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755503AbaISKO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:14:29 -0400
In-Reply-To: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

This patch adds speed reporting via ethtool for 20G KR2 interface on the
Skyhawk-R chip.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    1 +
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    7 +++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index b064c50..eb5085d 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1374,6 +1374,7 @@ enum {
 #define BE_SUPPORTED_SPEED_100MBPS	2
 #define BE_SUPPORTED_SPEED_1GBPS	4
 #define BE_SUPPORTED_SPEED_10GBPS	8
+#define BE_SUPPORTED_SPEED_20GBPS	0x10
 #define BE_SUPPORTED_SPEED_40GBPS	0x20
 
 #define BE_AN_EN			0x2
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 8297824..ec66f64 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -534,6 +534,13 @@ static u32 convert_to_et_setting(struct be_adapter *adapter, u32 if_speeds)
 		if (if_speeds & BE_SUPPORTED_SPEED_10GBPS)
 			val |= SUPPORTED_10000baseKX4_Full;
 		break;
+	case PHY_TYPE_KR2_20GB:
+		val |= SUPPORTED_Backplane;
+		if (if_speeds & BE_SUPPORTED_SPEED_10GBPS)
+			val |= SUPPORTED_10000baseKR_Full;
+		if (if_speeds & BE_SUPPORTED_SPEED_20GBPS)
+			val |= SUPPORTED_20000baseKR2_Full;
+		break;
 	case PHY_TYPE_KR_10GB:
 		val |= SUPPORTED_Backplane |
 				SUPPORTED_10000baseKR_Full;
-- 
1.7.1
