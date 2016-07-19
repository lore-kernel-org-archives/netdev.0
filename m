From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next v3 09/10] net/faraday: Match driver according to compatible property
Date: Tue, 19 Jul 2016 11:54:24 +1000
Message-ID: <1468893265-10635-10-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	gerlitz.or@gmail.com, weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57383 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752373AbcGSByh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 21:54:37 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6J1sHSj019820
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:54:37 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2495r8g118-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:54:36 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Tue, 19 Jul 2016 11:54:34 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id D50032CE802D
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:32 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6J1sWar23199796
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:32 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6J1sV9S020365
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:32 +1000
In-Reply-To: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
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
