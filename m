From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 2/3] bnx2x: Fix KR2 link
Date: Thu, 28 Feb 2013 01:06:45 +0200
Message-ID: <1362006406-2489-3-git-send-email-yanivr@broadcom.com>
References: <1362006406-2489-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3833 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751571Ab3B0VI0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 16:08:26 -0500
In-Reply-To: <1362006406-2489-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix KR2 link down problem after reboot when link speed is reconfigured via ethtool.
Since 1G/10G support link speed were missing by default, 1G/10G link speed were
not advertised.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    6 ++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |    2 ++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 9a674b1..edfa67a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -281,6 +281,8 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			cmd->lp_advertising |= ADVERTISED_2500baseX_Full;
 		if (status & LINK_STATUS_LINK_PARTNER_10GXFD_CAPABLE)
 			cmd->lp_advertising |= ADVERTISED_10000baseT_Full;
+		if (status & LINK_STATUS_LINK_PARTNER_20GXFD_CAPABLE)
+			cmd->lp_advertising |= ADVERTISED_20000baseKR2_Full;
 	}
 
 	cmd->maxtxpkt = 0;
@@ -463,6 +465,10 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 						ADVERTISED_10000baseKR_Full))
 				bp->link_params.speed_cap_mask[cfg_idx] |=
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_10G;
+
+			if (cmd->advertising & ADVERTISED_20000baseKR2_Full)
+				bp->link_params.speed_cap_mask[cfg_idx] |=
+					PORT_HW_CFG_SPEED_CAPABILITY_D0_20G;
 		}
 	} else { /* forced speed */
 		/* advertise the requested speed and duplex if supported */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 4719ab1..bf69c53 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -11851,6 +11851,8 @@ static int bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
 			phy->media_type = ETH_PHY_KR;
 			phy->flags |= FLAGS_WC_DUAL_MODE;
 			phy->supported &= (SUPPORTED_20000baseKR2_Full |
+					   SUPPORTED_10000baseT_Full |
+					   SUPPORTED_1000baseT_Full |
 					   SUPPORTED_Autoneg |
 					   SUPPORTED_FIBRE |
 					   SUPPORTED_Pause |
-- 
1.7.7.1
