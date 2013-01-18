From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] smsc: smc911x: Fix sparse warnings
Date: Fri, 18 Jan 2013 00:46:02 -0200
Message-ID: <1358477163-7582-1-git-send-email-festevam@gmail.com>
Cc: netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f178.google.com ([209.85.160.178]:46271 "EHLO
	mail-gh0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294Ab3ARDIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 22:08:44 -0500
Received: by mail-gh0-f178.google.com with SMTP id g24so461136ghb.37
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 19:08:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

ioremap returns 'void __iomem *' type.

Fix the following build warnings:

drivers/net/ethernet/smsc/smc911x.c:2079:14: warning: incorrect type in assignment (different address spaces)
drivers/net/ethernet/smsc/smc911x.c:2079:14:    expected unsigned int *addr
drivers/net/ethernet/smsc/smc911x.c:2079:14:    got void [noderef] <asn:2>*
drivers/net/ethernet/smsc/smc911x.c:2086:18: warning: incorrect type in assignment (different address spaces)
drivers/net/ethernet/smsc/smc911x.c:2086:18:    expected void [noderef] <asn:2>*base
drivers/net/ethernet/smsc/smc911x.c:2086:18:    got unsigned int *addr
drivers/net/ethernet/smsc/smc911x.c:2091:25: warning: incorrect type in argument 1 (different address spaces)
drivers/net/ethernet/smsc/smc911x.c:2091:25:    expected void volatile [noderef] <asn:2>*addr
drivers/net/ethernet/smsc/smc911x.c:2091:25:    got unsigned int *addr

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/smsc/smc911x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 1538d54..9dd842d 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -2036,7 +2036,7 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 	struct net_device *ndev;
 	struct resource *res;
 	struct smc911x_local *lp;
-	unsigned int *addr;
+	void __iomem *addr;
 	int ret;
 
 	DBG(SMC_DEBUG_FUNC, "--> %s\n",  __func__);
-- 
1.7.9.5
