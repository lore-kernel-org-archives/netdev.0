From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 06/12] qlge: bugfix: Tell hw to strip vlan header.
Date: Mon,  9 Mar 2009 13:59:22 -0700
Message-ID: <1236632368-22079-7-git-send-email-ron.mercer@qlogic.com>
References: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18643 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639AbZCIVDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 17:03:08 -0400
In-Reply-To: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 6da8901..8b6128e 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3073,9 +3073,9 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
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

