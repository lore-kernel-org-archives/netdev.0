From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 3/5] qlge: Fix bug in MTU setting process.
Date: Sun,  7 Jun 2009 16:58:27 -0700
Message-ID: <1244419109-355-4-git-send-email-ron.mercer@qlogic.com>
References: <1244419109-355-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:19996 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915AbZFHAGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 20:06:22 -0400
In-Reply-To: <1244419109-355-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since an FCoE function shares a port with this NIC function, the
jumbo settings must always be in place.  This patch causes the
hardware to be set up for jumbo if it is not already done.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index ff84243..de96b8a 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -761,7 +761,6 @@ void ql_mpi_port_cfg_work(struct work_struct *work)
 {
 	struct ql_adapter *qdev =
 	    container_of(work, struct ql_adapter, mpi_port_cfg_work.work);
-	struct net_device *ndev = qdev->ndev;
 	int status;
 
 	status = ql_mb_get_port_cfg(qdev);
@@ -771,9 +770,7 @@ void ql_mpi_port_cfg_work(struct work_struct *work)
 		goto err;
 	}
 
-	if (ndev->mtu <= 2500)
-		goto end;
-	else if (qdev->link_config & CFG_JUMBO_FRAME_SIZE &&
+	if (qdev->link_config & CFG_JUMBO_FRAME_SIZE &&
 			qdev->max_frame_size ==
 			CFG_DEFAULT_MAX_FRAME_SIZE)
 		goto end;
-- 
1.6.0.2

