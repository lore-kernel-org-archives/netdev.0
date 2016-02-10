From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 3/5] bnxt_en: Remove 20G support and advertise only 40GbaseCR4.
Date: Wed, 10 Feb 2016 17:33:48 -0500
Message-ID: <1455143630-30140-4-git-send-email-mchan@broadcom.com>
References: <1455143630-30140-1-git-send-email-mchan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:12624
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750759AbcBJWdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 17:33:51 -0500
In-Reply-To: <1455143630-30140-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

20G is not supported by production hardware and only the 40GbaseCR4 standard
is supported.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index afc9655..3238817 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -486,15 +486,8 @@ static u32 bnxt_fw_to_ethtool_support_spds(struct bnxt_link_info *link_info)
 		speed_mask |= SUPPORTED_2500baseX_Full;
 	if (fw_speeds & BNXT_LINK_SPEED_MSK_10GB)
 		speed_mask |= SUPPORTED_10000baseT_Full;
-	/* TODO: support 25GB, 50GB with different cable type */
-	if (fw_speeds & BNXT_LINK_SPEED_MSK_20GB)
-		speed_mask |= SUPPORTED_20000baseMLD2_Full |
-			SUPPORTED_20000baseKR2_Full;
 	if (fw_speeds & BNXT_LINK_SPEED_MSK_40GB)
-		speed_mask |= SUPPORTED_40000baseKR4_Full |
-			SUPPORTED_40000baseCR4_Full |
-			SUPPORTED_40000baseSR4_Full |
-			SUPPORTED_40000baseLR4_Full;
+		speed_mask |= SUPPORTED_40000baseCR4_Full;
 
 	return speed_mask;
 }
@@ -514,15 +507,8 @@ static u32 bnxt_fw_to_ethtool_advertised_spds(struct bnxt_link_info *link_info)
 		speed_mask |= ADVERTISED_2500baseX_Full;
 	if (fw_speeds & BNXT_LINK_SPEED_MSK_10GB)
 		speed_mask |= ADVERTISED_10000baseT_Full;
-	/* TODO: how to advertise 20, 25, 40, 50GB with different cable type ?*/
-	if (fw_speeds & BNXT_LINK_SPEED_MSK_20GB)
-		speed_mask |= ADVERTISED_20000baseMLD2_Full |
-			      ADVERTISED_20000baseKR2_Full;
 	if (fw_speeds & BNXT_LINK_SPEED_MSK_40GB)
-		speed_mask |= ADVERTISED_40000baseKR4_Full |
-			      ADVERTISED_40000baseCR4_Full |
-			      ADVERTISED_40000baseSR4_Full |
-			      ADVERTISED_40000baseLR4_Full;
+		speed_mask |= ADVERTISED_40000baseCR4_Full;
 	return speed_mask;
 }
 
@@ -659,6 +645,9 @@ static u16 bnxt_get_fw_auto_link_speeds(u32 advertising)
 	if (advertising & ADVERTISED_10000baseT_Full)
 		fw_speed_mask |= BNXT_LINK_SPEED_MSK_10GB;
 
+	if (advertising & ADVERTISED_40000baseCR4_Full)
+		fw_speed_mask |= BNXT_LINK_SPEED_MSK_40GB;
+
 	return fw_speed_mask;
 }
 
-- 
1.8.3.1
