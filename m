From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 2/2] qla3xxx: Don't sleep while holding lock.
Date: Tue, 23 Jun 2009 12:00:02 -0700
Message-ID: <1245783602-6542-2-git-send-email-ron.mercer@qlogic.com>
References: <1245783602-6542-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:35406 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754365AbZFWTF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 15:05:56 -0400
In-Reply-To: <1245783602-6542-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index d9e3835..56333ee 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3143,6 +3143,7 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 						(void __iomem *)port_regs;
 	u32 delay = 10;
 	int status = 0;
+	unsigned long hw_flags = 0;
 
 	if(ql_mii_setup(qdev))
 		return -1;
@@ -3352,7 +3353,9 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 		value = ql_read_page0_reg(qdev, &port_regs->portStatus);
 		if (value & PORT_STATUS_IC)
 			break;
+		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 		msleep(500);
+		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 	} while (--delay);
 
 	if (delay == 0) {
-- 
1.6.0.2

