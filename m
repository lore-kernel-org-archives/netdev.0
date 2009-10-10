From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 6/8] qlge: Get rid of firmware handler debug code.
Date: Sat, 10 Oct 2009 12:35:08 -0700
Message-ID: <1255203310-18114-7-git-send-email-ron.mercer@qlogic.com>
References: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55225 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934785AbZJJTnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 15:43:15 -0400
In-Reply-To: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |   21 ---------------------
 1 files changed, 0 insertions(+), 21 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 9c0dfe0..e497eac 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -1,25 +1,5 @@
 #include "qlge.h"
 
-static void ql_display_mb_sts(struct ql_adapter *qdev,
-						struct mbox_params *mbcp)
-{
-	int i;
-	static char *err_sts[] = {
-		"Command Complete",
-		"Command Not Supported",
-		"Host Interface Error",
-		"Checksum Error",
-		"Unused Completion Status",
-		"Test Failed",
-		"Command Parameter Error"};
-
-	QPRINTK(qdev, DRV, DEBUG, "%s.\n",
-		err_sts[mbcp->mbox_out[0] & 0x0000000f]);
-	for (i = 0; i < mbcp->out_count; i++)
-		QPRINTK(qdev, DRV, DEBUG, "mbox_out[%d] = 0x%.08x.\n",
-				i, mbcp->mbox_out[i]);
-}
-
 int ql_read_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 *data)
 {
 	int status;
@@ -540,7 +520,6 @@ static int ql_mailbox_command(struct ql_adapter *qdev, struct mbox_params *mbcp)
 					MB_CMD_STS_GOOD) &&
 		((mbcp->mbox_out[0] & 0x0000f000) !=
 					MB_CMD_STS_INTRMDT)) {
-		ql_display_mb_sts(qdev, mbcp);
 		status = -EIO;
 	}
 end:
-- 
1.6.0.2

