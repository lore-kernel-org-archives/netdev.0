From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next v2 09/10] net/faraday: Match driver according to compatible property
Date: Fri, 15 Jul 2016 20:44:19 +1000
Message-ID: <1468579460-13768-10-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1468579460-13768-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	gerlitz.or@gmail.com, weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:7007 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932550AbcGOKvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 06:51:06 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6FAnCoH069721
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 06:51:05 -0400
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com [125.16.236.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 246hekdj02-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 06:51:05 -0400
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Fri, 15 Jul 2016 16:21:01 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 71D49E0040
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 16:25:03 +0530 (IST)
Received: from d28av07.in.ibm.com (d28av07.in.ibm.com [9.184.220.146])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6FAonib30867584
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 16:20:50 +0530
Received: from d28av07.in.ibm.com (localhost [127.0.0.1])
	by d28av07.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6FAorP2030877
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 16:20:57 +0530
In-Reply-To: <1468579460-13768-1-git-send-email-gwshan@linux.vnet.ibm.com>
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
