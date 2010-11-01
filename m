From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-2.6 5/8] bnx2x: Fix resetting BCM8726 PHY during
 common init
Date: Mon, 1 Nov 2010 17:32:36 +0200
Message-ID: <1288625556.3533.17.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2338 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755815Ab0KAMOl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 08:14:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On BCM8726 based designs, the ports are swapped, hence the reset needs to be asserted through port0 and not port1.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index fdd7e03..488e251 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -7152,7 +7152,7 @@ static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp,
 		(1<<(MISC_REGISTERS_GPIO_3 + MISC_REGISTERS_GPIO_PORT_SHIFT)));
 	REG_WR(bp, MISC_REG_GPIO_EVENT_EN, val);
 
-	bnx2x_ext_phy_hw_reset(bp, 1);
+	bnx2x_ext_phy_hw_reset(bp, 0);
 	msleep(5);
 	for (port = 0; port < PORT_MAX; port++) {
 		u32 shmem_base, shmem2_base;
-- 
1.7.1




