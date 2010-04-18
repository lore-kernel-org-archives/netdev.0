From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 3/13] bnx2x: Increase DMAE max write size for 57711 to
 the max
Date: Sun, 18 Apr 2010 17:48:30 +0300
Message-ID: <1271602110.27235.180.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3308 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754796Ab0DROsn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 10:48:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase DMAE max write size for 57711 to the maximum allowed value.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    2 +-
 drivers/net/bnx2x_main.c |    9 +++++----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 0706c2c..fc00f79 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1165,7 +1165,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define DMAE_CMD_E1HVN_SHIFT		DMAE_COMMAND_E1HVN_SHIFT
 
 #define DMAE_LEN32_RD_MAX		0x80
-#define DMAE_LEN32_WR_MAX		0x400
+#define DMAE_LEN32_WR_MAX(bp)		(CHIP_IS_E1(bp) ? 0x400 : 0x2000)
 
 #define DMAE_COMP_VAL			0xe0d0d0ae
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 33d7484..da89cb0 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -352,13 +352,14 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
 			       u32 addr, u32 len)
 {
+	int dmae_wr_max = DMAE_LEN32_WR_MAX(bp);
 	int offset = 0;
 
-	while (len > DMAE_LEN32_WR_MAX) {
+	while (len > dmae_wr_max) {
 		bnx2x_write_dmae(bp, phys_addr + offset,
-				 addr + offset, DMAE_LEN32_WR_MAX);
-		offset += DMAE_LEN32_WR_MAX * 4;
-		len -= DMAE_LEN32_WR_MAX;
+				 addr + offset, dmae_wr_max);
+		offset += dmae_wr_max * 4;
+		len -= dmae_wr_max;
 	}
 
 	bnx2x_write_dmae(bp, phys_addr + offset, addr + offset, len);
-- 
1.6.3.3





