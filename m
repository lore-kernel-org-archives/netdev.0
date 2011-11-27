From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next 5/8] bnx2x: Change Warpcore MDIO work around mode
Date: Sun, 27 Nov 2011 20:17:58 +0200
Message-ID: <1322417881-17760-6-git-send-email-yanivr@broadcom.com>
References: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3748 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755795Ab1K0QTF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Nov 2011 11:19:05 -0500
In-Reply-To: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the usage of simpler MDC/MDIO work-around when accessing Warpcore registers.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index e821c4a..c734fff 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -11308,7 +11308,9 @@ static int bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
 				       offsetof(struct shmem_region,
 			dev_info.port_feature_config[port].link_config)) &
 			  PORT_FEATURE_CONNECTED_SWITCH_MASK);
-	chip_id = REG_RD(bp, MISC_REG_CHIP_NUM) << 16;
+	chip_id = (REG_RD(bp, MISC_REG_CHIP_NUM) << 16) |
+				((REG_RD(bp, MISC_REG_CHIP_REV) & 0xf) << 12);
+
 	DP(NETIF_MSG_LINK, ":chip_id = 0x%x\n", chip_id);
 	if (USES_WARPCORE(bp)) {
 		u32 serdes_net_if;
-- 
1.7.7.1
