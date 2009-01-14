From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 32/34]bnx2x: Handling PHY FW load failure
Date: Wed, 14 Jan 2009 18:44:24 +0200
Message-ID: <1231951464.11301.153.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3140 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764154AbZANQpi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:45:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the default PHY version (0x4321) is read - the PHY FW load failed

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 2fd6be0..b4527a4 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -4404,10 +4404,11 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 			      ext_phy_addr[port],
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
-		if (fw_ver1 == 0) {
+		if (fw_ver1 == 0 || fw_ver1 == 0x4321) {
 			DP(NETIF_MSG_LINK,
-				 "bnx2x_8073_common_init_phy port %x "
-				 "fw Download failed\n", port);
+				 "bnx2x_8073_common_init_phy port %x:"
+				 "Download failed. fw version = 0x%x\n",
+				 port, fw_ver1);
 			return -EINVAL;
 		}
 
-- 
1.5.4.3




