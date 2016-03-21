From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: smc911x: avoid unused variable warnings
Date: Mon, 21 Mar 2016 09:30:59 +0100
Message-ID: <1458549072-1914517-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Robert Jarzmik <robert.jarzmik@free.fr>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:55153 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbcCUIlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 04:41:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The change to use the generic DMA engine API in the smc911x
driver has led to a harmless warning about unused local variables:

smsc/smc911x.c: In function 'smc911x_probe':
smsc/smc911x.c:1796:20: error: unused variable 'param'
smsc/smc911x.c:1795:17: error: unused variable 'mask'
smsc/smc911x.c:1794:26: error: unused variable 'config'

This puts the variable declarations inside of the same #ifdef
that protects their use.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 79d3b59a93ba ("net: smc911x: convert pxa dma to dmaengine")
---
 drivers/net/ethernet/smsc/smc911x.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 3f5711061432..a733868a43aa 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -1791,9 +1791,11 @@ static int smc911x_probe(struct net_device *dev)
 	unsigned int val, chip_id, revision;
 	const char *version_string;
 	unsigned long irq_flags;
+#ifdef SMC_USE_DMA
 	struct dma_slave_config	config;
 	dma_cap_mask_t mask;
 	struct pxad_param param;
+#endif
 
 	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
-- 
2.7.0
