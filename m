From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v3 2/3] net/fec: fix fec1 check in fec_enet_mii_init()
Date: Thu, 22 Sep 2011 00:07:49 +0800
Message-ID: <1316621270-27805-3-git-send-email-shawn.guo@linaro.org>
References: <1316621270-27805-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<patches@linaro.org>, Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe002.messaging.microsoft.com ([213.199.154.140]:53513
	"EHLO DB3EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752392Ab1IUP6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 11:58:51 -0400
In-Reply-To: <1316621270-27805-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function fec_enet_mii_init(), it uses non-zero pdev->id as part
of the condition to check the second fec instance (fec1).  This works
before the driver supports device tree probe.  But in case of device
tree probe, pdev->id is -1 which is also non-zero, so the logic becomes
broken when device tree probe gets supported.

The patch change the logic to check "pdev->id > 0" as the part of the
condition for identifying fec1.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 9c1d059..2bbe6a5 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -996,7 +996,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	 * mdio interface in board design, and need to be configured by
 	 * fec0 mii_bus.
 	 */
-	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && pdev->id) {
+	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && pdev->id > 0) {
 		/* fec1 uses fec0 mii_bus */
 		fep->mii_bus = fec0_mii_bus;
 		return 0;
-- 
1.7.4.1
