From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 3/6] bnx2: Adjust flow control water marks.
Date: Mon, 15 Feb 2010 21:42:09 -0800
Message-ID: <1266298932-28129-3-git-send-email-mchan@broadcom.com>
References: <1266298932-28129-1-git-send-email-mchan@broadcom.com>
 <1266298932-28129-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3644 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308Ab0BPFdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 00:33:01 -0500
In-Reply-To: <1266298932-28129-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current water marks are too high and can cause unnecessary flow
control frames.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |    2 +-
 drivers/net/bnx2.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 063f283..54d43d8 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1277,7 +1277,7 @@ bnx2_init_rx_context(struct bnx2 *bp, u32 cid)
 		if (lo_water >= bp->rx_ring_size)
 			lo_water = 0;
 
-		hi_water = bp->rx_ring_size / 4;
+		hi_water = min_t(int, bp->rx_ring_size / 4, lo_water + 16);
 
 		if (hi_water <= lo_water)
 			lo_water = 0;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index b860fbb..cd4b0e4 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -349,7 +349,7 @@ struct l2_fhdr {
 #define BNX2_L2CTX_BD_PRE_READ				0x00000000
 #define BNX2_L2CTX_CTX_SIZE				0x00000000
 #define BNX2_L2CTX_CTX_TYPE				0x00000000
-#define BNX2_L2CTX_LO_WATER_MARK_DEFAULT		 32
+#define BNX2_L2CTX_LO_WATER_MARK_DEFAULT		 4
 #define BNX2_L2CTX_LO_WATER_MARK_SCALE			 4
 #define BNX2_L2CTX_LO_WATER_MARK_DIS			 0
 #define BNX2_L2CTX_HI_WATER_MARK_SHIFT			 4
-- 
1.6.4.GIT


