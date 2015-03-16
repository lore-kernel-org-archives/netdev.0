From: <shh.xie@gmail.com>
Subject: [PATCH 1/2] [v2] net/fsl: fix a bug in xgmac_mdio
Date: Mon, 16 Mar 2015 18:55:50 +0800
Message-ID: <1426503350-23181-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0064.outbound.protection.outlook.com ([207.46.100.64]:48544
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751475AbbCPMDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2015 08:03:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

There is a bug in xgmac_wait_until_done() which mdio_stat should be used
instead of mdio_data when checking if busy bit is cleared.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
changes for v2:
splitted from http://patchwork.ozlabs.org/patch/450392/

 drivers/net/ethernet/freescale/xgmac_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index 3a83bc2..5f691f2 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -79,7 +79,7 @@ static int xgmac_wait_until_done(struct device *dev,
 
 	/* Wait till the MDIO write is complete */
 	timeout = TIMEOUT;
-	while ((ioread32be(&regs->mdio_data) & MDIO_DATA_BSY) && timeout) {
+	while ((ioread32be(&regs->mdio_stat) & MDIO_STAT_BSY) && timeout) {
 		cpu_relax();
 		timeout--;
 	}
-- 
1.8.4.1
