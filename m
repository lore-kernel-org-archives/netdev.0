From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 06/41]bnx2x: Removing microcode assertion check
Date: Thu, 12 Feb 2009 20:36:27 +0200
Message-ID: <1234463787.1863.137.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758080AbZBLSg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:36:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 06/41]bnx2x: Removing microcode assertion check
This check is unreliable since latest MC can issue warnings on rare occasions
which are not fatal errors

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    2 +-
 drivers/net/bnx2x_main.c |    6 +-----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 89a72c8..cfbeabb 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1009,7 +1009,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 
 
 #define BNX2X_NUM_STATS			42
-#define BNX2X_NUM_TESTS			8
+#define BNX2X_NUM_TESTS			7
 
 #define BNX2X_MAC_LOOPBACK		0
 #define BNX2X_PHY_LOOPBACK		1
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ea7d86d..c27be17 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8732,8 +8732,7 @@ static const struct {
 	{ "nvram_test (online)" },
 	{ "interrupt_test (online)" },
 	{ "link_test (online)" },
-	{ "idle check (online)" },
-	{ "MC errors (online)" }
+	{ "idle check (online)" }
 };
 
 static int bnx2x_self_test_count(struct net_device *dev)
@@ -9202,9 +9201,6 @@ static void bnx2x_self_test(struct net_device *dev,
 			buf[5] = 1;
 			etest->flags |= ETH_TEST_FL_FAILED;
 		}
-	buf[7] = bnx2x_mc_assert(bp);
-	if (buf[7] != 0)
-		etest->flags |= ETH_TEST_FL_FAILED;
 
 #ifdef BNX2X_EXTRA_DEBUG
 	bnx2x_panic_dump(bp);
-- 
1.5.4.3




