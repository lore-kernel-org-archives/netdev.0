From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH] qla3xxx: don't allow never end busy loop
Date: Tue,  6 Jan 2015 23:17:53 +0200
Message-ID: <1420579073-24637-1-git-send-email-andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
To: netdev@vger.kernel.org, linux-driver@qlogic.com,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw01.mail.saunalahti.fi ([195.197.172.115]:41969 "EHLO
	gw01.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218AbbAFVZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 16:25:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The counter variable wasn't increased at all which may stuck under
certain circumstances.

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 drivers/net/ethernet/qlogic/qla3xxx.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index c2f09af..4847713 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -146,10 +146,7 @@ static int ql_wait_for_drvr_lock(struct ql3_adapter *qdev)
 {
 	int i = 0;
 
-	while (i < 10) {
-		if (i)
-			ssleep(1);
-
+	do {
 		if (ql_sem_lock(qdev,
 				QL_DRVR_SEM_MASK,
 				(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index)
@@ -158,7 +155,8 @@ static int ql_wait_for_drvr_lock(struct ql3_adapter *qdev)
 				      "driver lock acquired\n");
 			return 1;
 		}
-	}
+		ssleep(1);
+	} while (++i < 10);
 
 	netdev_err(qdev->ndev, "Timed out waiting for driver lock...\n");
 	return 0;
-- 
1.8.3.101.g727a46b
