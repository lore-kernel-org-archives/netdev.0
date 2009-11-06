From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 1/2] qlge: Fix early exit from mbox cmd complete wait.
Date: Fri,  6 Nov 2009 09:44:57 -0800
Message-ID: <1257529498-17459-2-git-send-email-ron.mercer@qlogic.com>
References: <1257529498-17459-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26379 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753328AbZKFRvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 12:51:21 -0500
In-Reply-To: <1257529498-17459-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This line was accidentally left out of the previous commit #
da03945140a035a2962f7f93e359085596f20499.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index bcf13c9..aec05f2 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -499,7 +499,7 @@ static int ql_mailbox_command(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		/* Wait for the interrupt to come in. */
 		status = ql_wait_mbx_cmd_cmplt(qdev);
 		if (status)
-			goto end;
+			continue;
 
 		/* Process the event.  If it's an AEN, it
 		 * will be handled in-line or a worker
-- 
1.6.0.2

