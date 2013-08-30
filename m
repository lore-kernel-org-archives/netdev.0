From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 09/31] net: ethoc: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:55:46 +0900
Message-ID: <003901cea53d$30c57c80$92507580$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:59153 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675Ab3H3Ezw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:55:52 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB005DMUZWYYO0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:55:46 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/ethoc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index cf579fb..4de8cfd 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1030,8 +1030,8 @@ static int ethoc_probe(struct platform_device *pdev)
 	}
 
 	/* Allow the platform setup code to pass in a MAC address. */
-	if (pdev->dev.platform_data) {
-		struct ethoc_platform_data *pdata = pdev->dev.platform_data;
+	if (dev_get_platdata(&pdev->dev)) {
+		struct ethoc_platform_data *pdata = dev_get_platdata(&pdev->dev);
 		memcpy(netdev->dev_addr, pdata->hwaddr, IFHWADDRLEN);
 		priv->phy_id = pdata->phy_id;
 	} else {
-- 
1.7.10.4
