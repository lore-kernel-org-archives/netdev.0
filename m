From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 09/10] net/farady: Match driver according to compatible property
Date: Sun,  3 Jul 2016 15:32:32 +1000
Message-ID: <1467523953-18998-10-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	weixue@trustnetic.com, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57566 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751259AbcGCFcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 01:32:47 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u635TJmd098910
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 01:32:46 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23x7xd979g-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 01:32:46 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Sun, 3 Jul 2016 15:32:44 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id D1FFB2CE8057
	for <netdev@vger.kernel.org>; Sun,  3 Jul 2016 15:32:41 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u635WfPo5046706
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 15:32:41 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u635We4N027252
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 15:32:41 +1000
In-Reply-To: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This matches the driver with devices compatible with "faraday,ftgmac100"
declared in the device tree. Originally, device's name from device
tree for it.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Acked-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 1cd4975..d8afa2d 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1438,14 +1438,20 @@ static int __exit ftgmac100_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static const struct of_device_id ftgmac100_of_match[] = {
+	{ .compatible = "faraday,ftgmac100" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, ftgmac100_of_match);
+
 static struct platform_driver ftgmac100_driver = {
-	.probe		= ftgmac100_probe,
-	.remove		= __exit_p(ftgmac100_remove),
-	.driver		= {
-		.name	= DRV_NAME,
+	.probe	= ftgmac100_probe,
+	.remove	= __exit_p(ftgmac100_remove),
+	.driver	= {
+		.name		= DRV_NAME,
+		.of_match_table	= ftgmac100_of_match,
 	},
 };
-
 module_platform_driver(ftgmac100_driver);
 
 MODULE_AUTHOR("Po-Yu Chuang <ratbert@faraday-tech.com>");
-- 
2.1.0
