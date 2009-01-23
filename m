From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 07/21] [next] qlge: Remove lock protection in adapter up/down.
Date: Fri, 23 Jan 2009 07:16:25 -0800
Message-ID: <1232723799-8620-7-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987AbZAWPRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:17:47 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is nothing to contend at these points.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 0db99b4..97b72a6 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3183,12 +3183,10 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 
 	ql_tx_ring_clean(qdev);
 
-	spin_lock(&qdev->hw_lock);
 	status = ql_adapter_reset(qdev);
 	if (status)
 		QPRINTK(qdev, IFDOWN, ERR, "reset(func #%d) FAILED!\n",
 			qdev->func);
-	spin_unlock(&qdev->hw_lock);
 	return status;
 }
 
@@ -3196,14 +3194,11 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 {
 	int err = 0;
 
-	spin_lock(&qdev->hw_lock);
 	err = ql_adapter_initialize(qdev);
 	if (err) {
 		QPRINTK(qdev, IFUP, INFO, "Unable to initialize adapter.\n");
-		spin_unlock(&qdev->hw_lock);
 		goto err_init;
 	}
-	spin_unlock(&qdev->hw_lock);
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
 	ql_enable_interrupts(qdev);
 	ql_enable_all_completion_interrupts(qdev);
-- 
1.6.0.2

