From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 7/7] qlge: Add disable/enable firmare irqs to handler.
Date: Thu,  8 Oct 2009 12:54:43 -0700
Message-ID: <1255031683-3912-8-git-send-email-ron.mercer@qlogic.com>
References: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:40572 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933376AbZJHUDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 16:03:05 -0400
In-Reply-To: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was accidentally omitted from one of the previous patches for firmware event
handling.  The handler needs to the enable firmware irq mask when it's done
processing or it may not get any more events interrupts.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 8810f5b..99e58e3 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -965,6 +965,8 @@ void ql_mpi_work(struct work_struct *work)
 	int err = 0;
 
 	rtnl_lock();
+	/* Begin polled mode for MPI */
+	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16));
 
 	while (ql_read32(qdev, STS) & STS_PI) {
 		memset(mbcp, 0, sizeof(struct mbox_params));
@@ -977,6 +979,8 @@ void ql_mpi_work(struct work_struct *work)
 			break;
 	}
 
+	/* End polled mode for MPI */
+	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16) | INTR_MASK_PI);
 	rtnl_unlock();
 	ql_enable_completion_interrupt(qdev, 0);
 }
-- 
1.6.0.2

