From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-2.6 3/5] bnx2x: Fix port swap for BCM8073
Date: Sun, 30 Jan 2011 16:15:00 +0200
Message-ID: <1296396900.10095.52.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1629 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754325Ab1A3ORn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jan 2011 09:17:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix link on BCM57712 + BCM8073 when port swap is enabled. Common PHY reset was done on the wrong port.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/bnx2x/bnx2x_link.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index b1c667a..dd1210f 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -7688,10 +7688,13 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp,
 	struct bnx2x_phy phy[PORT_MAX];
 	struct bnx2x_phy *phy_blk[PORT_MAX];
 	u16 val;
-	s8 port;
+	s8 port = 0;
 	s8 port_of_path = 0;
-
-	bnx2x_ext_phy_hw_reset(bp, 0);
+	u32 swap_val, swap_override;
+	swap_val = REG_RD(bp,  NIG_REG_PORT_SWAP);
+	swap_override = REG_RD(bp,  NIG_REG_STRAP_OVERRIDE);
+	port ^= (swap_val && swap_override);
+	bnx2x_ext_phy_hw_reset(bp, port);
 	/* PART1 - Reset both phys */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
 		u32 shmem_base, shmem2_base;
-- 
1.7.1







