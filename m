From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 09/12] qlge: Remove spinlock from asic init path.
Date: Mon,  9 Mar 2009 13:59:25 -0700
Message-ID: <1236632368-22079-10-git-send-email-ron.mercer@qlogic.com>
References: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18643 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739AbZCIVDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 17:03:12 -0400
In-Reply-To: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is nothing to contend with it.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 75ad4db..f7f104a 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3250,14 +3250,12 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 {
 	int err = 0;
 
-	spin_lock(&qdev->hw_lock);
 	err = ql_adapter_initialize(qdev);
 	if (err) {
 		QPRINTK(qdev, IFUP, INFO, "Unable to initialize adapter.\n");
 		spin_unlock(&qdev->hw_lock);
 		goto err_init;
 	}
-	spin_unlock(&qdev->hw_lock);
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
 	ql_alloc_rx_buffers(qdev);
 	if ((ql_read32(qdev, STS) & qdev->port_init))
-- 
1.6.0.2

