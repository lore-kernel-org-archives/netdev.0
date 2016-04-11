From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Subject: [PATCH] net: fjes: Use resource_size
Date: Mon, 11 Apr 2016 15:58:17 +0530
Message-ID: <1460370497-10221-1-git-send-email-vaishali.thakkar@oracle.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Vaishali Thakkar <vaishali.thakkar@oracle.com>
To: izumi.taku@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23198 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbcDKKaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 06:30:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the function resource_size instead of explicit computation.

Problem found using Coccinelle.

Signed-off-by: Vaishali Thakkar <vaishali.thakkar@oracle.com>
---
 drivers/net/fjes/fjes_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 0ddb54f..061b4af 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -1129,7 +1129,7 @@ static int fjes_probe(struct platform_device *plat_dev)
 
 	res = platform_get_resource(plat_dev, IORESOURCE_MEM, 0);
 	hw->hw_res.start = res->start;
-	hw->hw_res.size = res->end - res->start + 1;
+	hw->hw_res.size = resource_size(res);
 	hw->hw_res.irq = platform_get_irq(plat_dev, 0);
 	err = fjes_hw_init(&adapter->hw);
 	if (err)
-- 
2.1.4
