From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 04/21] [next] qlge: Clean up adapter reset function.
Date: Fri, 23 Jan 2009 07:16:22 -0800
Message-ID: <1232723799-8620-4-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbZAWPRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:17:45 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some debug junk.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   23 +++++------------------
 1 files changed, 5 insertions(+), 18 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 340a8ac..60d3c31 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3093,36 +3093,23 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 static int ql_adapter_reset(struct ql_adapter *qdev)
 {
 	u32 value;
-	int max_wait_time;
+	int max_wait_time = 3;
 	int status = 0;
-	int resetCnt = 0;
 
-#define MAX_RESET_CNT   1
-issueReset:
-	resetCnt++;
-	QPRINTK(qdev, IFDOWN, DEBUG, "Issue soft reset to chip.\n");
 	ql_write32(qdev, RST_FO, (RST_FO_FR << 16) | RST_FO_FR);
-	/* Wait for reset to complete. */
+
 	max_wait_time = 3;
-	QPRINTK(qdev, IFDOWN, DEBUG, "Wait %d seconds for reset to complete.\n",
-		max_wait_time);
 	do {
 		value = ql_read32(qdev, RST_FO);
 		if ((value & RST_FO_FR) == 0)
 			break;
-
-		ssleep(1);
+		udelay(10);
 	} while ((--max_wait_time));
-	if (value & RST_FO_FR) {
-		QPRINTK(qdev, IFDOWN, ERR,
-			"Stuck in SoftReset:  FSC_SR:0x%08x\n", value);
-		if (resetCnt < MAX_RESET_CNT)
-			goto issueReset;
-	}
+
 	if (max_wait_time == 0) {
-		status = -ETIMEDOUT;
 		QPRINTK(qdev, IFDOWN, ERR,
 			"ETIMEOUT!!! errored out of resetting the chip!\n");
+		status = -ETIMEDOUT;
 	}
 
 	return status;
-- 
1.6.0.2

