From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH net-next 3/7] net:fec: remove checking for NULL phy_dev in fec_enet_close()
Date: Tue, 29 Apr 2014 20:09:06 +0800
Message-ID: <1398773350-7293-3-git-send-email-Frank.Li@freescale.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0208.outbound.protection.outlook.com ([207.46.163.208]:7038
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751400AbaD2NUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 09:20:41 -0400
In-Reply-To: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>

fep->phy_dev can not be NULL here for two reasons:
- fec_enet_open() will have successfully connected the phy, or will have
  failed.
- fec_enet_open() will have called phy_start(fep->phy_dev), which
  unconditionally dereferences this pointer.

If it were to be NULL here, then fec_enet_open() will have already
oopsed.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 875c0ca..b7a5614 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1798,10 +1798,8 @@ fec_enet_close(struct net_device *ndev)
 	netif_stop_queue(ndev);
 	fec_stop(ndev);
 
-	if (fep->phy_dev) {
-		phy_stop(fep->phy_dev);
-		phy_disconnect(fep->phy_dev);
-	}
+	phy_stop(fep->phy_dev);
+	phy_disconnect(fep->phy_dev);
 
 	fec_enet_free_buffers(ndev);
 
-- 
1.7.8
