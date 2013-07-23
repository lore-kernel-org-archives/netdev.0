From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH 12/27] drivers/net/ethernet/stmicro/stmmac: don't check resource with devm_ioremap_resource
Date: Tue, 23 Jul 2013 20:01:45 +0200
Message-ID: <1374602524-3398-13-git-send-email-wsa@the-dreams.de>
References: <1374602524-3398-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sauhun.de ([89.238.76.85]:58734 "EHLO pokefinder.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933908Ab3GWSDP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jul 2013 14:03:15 -0400
In-Reply-To: <1374602524-3398-1-git-send-email-wsa@the-dreams.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devm_ioremap_resource does sanity checks on the given resource. No need to
duplicate this in the driver.

Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
---
Please apply via the subsystem-tree.

 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 03de76c..da8be6e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -109,9 +109,6 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 	const char *mac = NULL;
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!res)
-		return -ENODEV;
-
 	addr = devm_ioremap_resource(dev, res);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
-- 
1.7.10.4
