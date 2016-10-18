From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH v2 1/2] dwc_eth_qos: do not clear pause flags from phy_device->supported
Date: Tue, 18 Oct 2016 09:20:33 +0200
Message-ID: <1476775233-14633-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, Niklas Cassel <niklass@axis.com>,
        Jesper Nilsson <jespern@axis.com>
To: <larper@axis.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:57760 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750763AbcJRHUv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 03:20:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niklas Cassel <niklas.cassel@axis.com>

phy_device->supported is originally set by the PHY driver.
The ethernet driver should filter phy_device->supported to only contain
flags supported by the IP.
The IP supports setting rx and tx flow control independently,
therefore SUPPORTED_Pause and SUPPORTED_Asym_Pause should not be cleared.
If the flags are cleared, pause frames cannot be enabled (even if they
are supported by the PHY).

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
Signed-off-by: Jesper Nilsson <jespern@axis.com>
Acked-by: Lars Persson <larper@axis.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 0d0053128542..d775729648ef 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -982,7 +982,8 @@ static int dwceqos_mii_probe(struct net_device *ndev)
 	if (netif_msg_probe(lp))
 		phy_attached_info(phydev);
 
-	phydev->supported &= PHY_GBIT_FEATURES;
+	phydev->supported &= PHY_GBIT_FEATURES | SUPPORTED_Pause |
+			     SUPPORTED_Asym_Pause;
 
 	lp->link    = 0;
 	lp->speed   = 0;
-- 
2.1.4
