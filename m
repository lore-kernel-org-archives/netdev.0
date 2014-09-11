From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next] ethernet: amd: use pr_info_once()
Date: Thu, 11 Sep 2014 12:50:50 +0530
Message-ID: <1410420050-16088-1-git-send-email-varkab@cdac.in>
Cc: davem@davemloft.net, Thomas.Lendacky@amd.com,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:37520 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaIKHX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 03:23:27 -0400
Received: by mail-pd0-f174.google.com with SMTP id v10so12727131pde.5
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 00:23:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will use pr_info_one() to print the version info of the
driver in probe function only once. No need to use the static
variable here.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/amd/au1000_eth.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 31c48a7..6c323f4 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1140,7 +1140,6 @@ static const struct net_device_ops au1000_netdev_ops = {
 
 static int au1000_probe(struct platform_device *pdev)
 {
-	static unsigned version_printed;
 	struct au1000_private *aup = NULL;
 	struct au1000_eth_platform_data *pd;
 	struct net_device *dev = NULL;
@@ -1371,9 +1370,8 @@ static int au1000_probe(struct platform_device *pdev)
 
 	netdev_info(dev, "Au1xx0 Ethernet found at 0x%lx, irq %d\n",
 			(unsigned long)base->start, irq);
-	if (version_printed++ == 0)
-		pr_info("%s version %s %s\n",
-					DRV_NAME, DRV_VERSION, DRV_AUTHOR);
+
+	pr_info_once("%s version %s %s\n", DRV_NAME, DRV_VERSION, DRV_AUTHOR);
 
 	return 0;
 
-- 
1.7.9.5
