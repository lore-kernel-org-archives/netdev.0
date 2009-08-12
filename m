From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 19/36] bnx2x: Stop loading if error condition
 detected
Date: Wed, 12 Aug 2009 21:23:31 +0300
Message-ID: <1250101411.27379.171.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Benjamin Li" <benli@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4884 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343AbZHLSYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    1 +
 drivers/net/bnx2x_main.c |    8 ++++++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 004f4a8..633acca 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -89,6 +89,7 @@
 	} while (0)
 #else
 #define bnx2x_panic() do { \
+		bp->panic = 1; \
 		BNX2X_ERR("driver assert\n"); \
 		bnx2x_panic_dump(bp); \
 	} while (0)
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 9eea52d..8e32134 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7108,6 +7108,9 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 		}
 
 		msleep(1);
+
+		if (bp->panic)
+			return -EIO;
 	}
 
 	/* timeout! */
@@ -7372,7 +7375,12 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	rc = bnx2x_setup_leading(bp);
 	if (rc) {
 		BNX2X_ERR("Setup leading failed!\n");
+#ifndef BNX2X_STOP_ON_ERROR
 		goto load_error3;
+#else
+		bp->panic = 1;
+		return -EBUSY;
+#endif
 	}
 
 	if (CHIP_IS_E1H(bp))
-- 
1.5.4.3




