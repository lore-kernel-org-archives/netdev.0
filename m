From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 5/5] qlge: Fix timeout on firmware mailbox commands.
Date: Sun,  7 Jun 2009 16:58:29 -0700
Message-ID: <1244419109-355-6-git-send-email-ron.mercer@qlogic.com>
References: <1244419109-355-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:19996 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202AbZFHAGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 20:06:23 -0400
In-Reply-To: <1244419109-355-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some firmware mailbox commands require the firmware to
communicate with the FCoE driver running on another
PCI function.  This can potentially take several seconds.
This wait is done in process context only.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index de96b8a..3bd60a4 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -90,14 +90,14 @@ static int ql_get_mb_sts(struct ql_adapter *qdev, struct mbox_params *mbcp)
  */
 static int ql_wait_mbx_cmd_cmplt(struct ql_adapter *qdev)
 {
-	int count = 50;	/* TODO: arbitrary for now. */
+	int count = 100;
 	u32 value;
 
 	do {
 		value = ql_read32(qdev, STS);
 		if (value & STS_PI)
 			return 0;
-		udelay(UDELAY_DELAY); /* 10us */
+		mdelay(UDELAY_DELAY); /* 100ms */
 	} while (--count);
 	return -ETIMEDOUT;
 }
-- 
1.6.0.2

