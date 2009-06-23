From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 1/2] qla3xxx: Give the PHY time to come out of reset.
Date: Tue, 23 Jun 2009 12:00:01 -0700
Message-ID: <1245783602-6542-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:35406 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888AbZFWTF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 15:05:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index cadc32c..d9e3835 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3151,7 +3151,8 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
 			    (ISP_SERIAL_PORT_IF_WE |
 			     (ISP_SERIAL_PORT_IF_WE << 16)));
-
+	/* Give the PHY time to come out of reset. */
+	mdelay(100);
 	qdev->port_link_state = LS_DOWN;
 	netif_carrier_off(qdev->ndev);
 
-- 
1.6.0.2

