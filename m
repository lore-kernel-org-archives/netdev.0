From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/8] qlge: Add firmware support for insert/remove SFP.
Date: Tue,  3 Mar 2009 14:10:30 -0800
Message-ID: <1236118237-14483-2-git-send-email-ron.mercer@qlogic.com>
References: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50781 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761744AbZCCWNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:13:52 -0500
In-Reply-To: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index ef610c6..ebb7b0c 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -200,6 +200,36 @@ exit:
 	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
 }
 
+static int ql_sfp_in(struct ql_adapter *qdev, struct mbox_params *mbcp)
+{
+	int status;
+
+	mbcp->out_count = 5;
+
+	status = ql_get_mb_sts(qdev, mbcp);
+	if (status)
+		QPRINTK(qdev, DRV, ERR, "SFP in AEN broken!\n");
+	else
+		QPRINTK(qdev, DRV, ERR, "SFP insertion detected.\n");
+
+	return status;
+}
+
+static int ql_sfp_out(struct ql_adapter *qdev, struct mbox_params *mbcp)
+{
+	int status;
+
+	mbcp->out_count = 1;
+
+	status = ql_get_mb_sts(qdev, mbcp);
+	if (status)
+		QPRINTK(qdev, DRV, ERR, "SFP out AEN broken!\n");
+	else
+		QPRINTK(qdev, DRV, ERR, "SFP removal detected.\n");
+
+	return status;
+}
+
 static void ql_init_fw_done(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
 	mbcp->out_count = 2;
@@ -284,6 +314,14 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		ql_init_fw_done(qdev, mbcp);
 		break;
 
+	case AEN_AEN_SFP_IN:
+		ql_sfp_in(qdev, mbcp);
+		break;
+
+	case AEN_AEN_SFP_OUT:
+		ql_sfp_out(qdev, mbcp);
+		break;
+
 	case AEN_FW_INIT_FAIL:
 	case AEN_SYS_ERR:
 		ql_queue_fw_error(qdev);
-- 
1.6.0.2

