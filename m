From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 7/8] qlge: Save status from firmware crash (system err).
Date: Tue,  3 Mar 2009 14:10:36 -0800
Message-ID: <1236118237-14483-8-git-send-email-ron.mercer@qlogic.com>
References: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50781 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757106AbZCCWOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:14:04 -0500
In-Reply-To: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 2c1d220..f9a2371 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -415,7 +415,10 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		break;
 
 	case AEN_SYS_ERR:
+		QPRINTK(qdev, DRV, ERR,
+			"System Error.\n");
 		ql_queue_fw_error(qdev);
+		status = -EIO;
 		break;
 
 	default:
-- 
1.6.0.2

