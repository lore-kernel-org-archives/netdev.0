From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 4/8] qlge: Fix redundant call to free resources.
Date: Thu,  2 Jul 2009 09:06:09 -0700
Message-ID: <1246550773-18417-4-git-send-email-ron.mercer@qlogic.com>
References: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26904 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947AbZGBQLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 12:11:33 -0400
In-Reply-To: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The caller will free acquired resouces if a failure occurs.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c226257..1b75f6e 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3374,11 +3374,6 @@ static int ql_get_adapter_resources(struct ql_adapter *qdev)
 		return -ENOMEM;
 	}
 	status = ql_request_irq(qdev);
-	if (status)
-		goto err_irq;
-	return status;
-err_irq:
-	ql_free_mem_resources(qdev);
 	return status;
 }
 
-- 
1.6.0.2

