From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 07/11] net/stmmac: mark probe function as __devinit
Date: Wed,  8 Aug 2012 16:47:24 +0200
Message-ID: <1344437248-20560-8-git-send-email-arnd@arndb.de>
References: <1344437248-20560-1-git-send-email-arnd@arndb.de>
Cc: arm@kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>, Stefan Roese <sr@denx.de>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:64940 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758580Ab2HHOri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 10:47:38 -0400
In-Reply-To: <1344437248-20560-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver probe functions are generally __devinit so they will be
discarded after initialization for non-hotplug kernels.
This was found by a new warning after patch 6a228452d "stmmac: Add
device-tree support" adds a new __devinit function that is called
from stmmac_pltfr_probe.

Without this patch, building socfpga_defconfig results in:

WARNING: drivers/net/ethernet/stmicro/stmmac/stmmac.o(.text+0x5d4c): Section mismatch in reference from the function stmmac_pltfr_probe() to the function .devinit.text:stmmac_probe_config_dt()
The function stmmac_pltfr_probe() references
the function __devinit stmmac_probe_config_dt().
This is often because stmmac_pltfr_probe lacks a __devinit
annotation or the annotation of stmmac_probe_config_dt is wrong.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Stefan Roese <sr@denx.de>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index cd01ee7..b93245c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -74,7 +74,7 @@ static int __devinit stmmac_probe_config_dt(struct platform_device *pdev,
  * the necessary resources and invokes the main to init
  * the net device, register the mdio bus etc.
  */
-static int stmmac_pltfr_probe(struct platform_device *pdev)
+static int __devinit stmmac_pltfr_probe(struct platform_device *pdev)
 {
 	int ret = 0;
 	struct resource *res;
-- 
1.7.10
