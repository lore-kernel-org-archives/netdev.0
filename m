From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v3 5/5] ethernet: samsung: sxgbe: remove unnecessary check
Date: Fri, 24 Oct 2014 07:42:10 +0530
Message-ID: <1414116730-4590-6-git-send-email-varkab@cdac.in>
References: <1414116730-4590-1-git-send-email-varkab@cdac.in>
Cc: davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:60609 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221AbaJXCPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 22:15:24 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so228200pab.10
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 19:15:23 -0700 (PDT)
In-Reply-To: <1414116730-4590-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devm_ioremap_resource checks platform_get_resource() return value.
We can remove the duplicate check here.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 .../net/ethernet/samsung/sxgbe/sxgbe_platform.c    |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
index b147d46..7fd6e27 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
@@ -90,9 +90,6 @@ static int sxgbe_platform_probe(struct platform_device *pdev)
 
 	/* Get memory resource */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!res)
-		goto err_out;
-
 	addr = devm_ioremap_resource(dev, res);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
-- 
1.7.9.5
