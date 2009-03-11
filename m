From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 2/4] qlge: bugfix: Tell hw to strip vlan header.
Date: Wed, 11 Mar 2009 14:55:41 -0700
Message-ID: <1236808543-11165-3-git-send-email-ron.mercer@qlogic.com>
References: <1236808543-11165-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:2059 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754963AbZCKV7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 17:59:35 -0400
In-Reply-To: <1236808543-11165-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 87787b1..54d54ea 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2984,9 +2984,9 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 	mask = value << 16;
 	ql_write32(qdev, SYS, mask | value);
 
-	/* Set the default queue. */
-	value = NIC_RCV_CFG_DFQ;
-	mask = NIC_RCV_CFG_DFQ_MASK;
+	/* Set the default queue, and VLAN behavior. */
+	value = NIC_RCV_CFG_DFQ | NIC_RCV_CFG_RV;
+	mask = NIC_RCV_CFG_DFQ_MASK | (NIC_RCV_CFG_RV << 16);
 	ql_write32(qdev, NIC_RCV_CFG, (mask | value));
 
 	/* Set the MPI interrupt to enabled. */
-- 
1.6.0.2

