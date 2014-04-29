From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH net-next 7/7] net:fec: iMX6 FEC does not support half-duplex gigabit
Date: Tue, 29 Apr 2014 20:09:10 +0800
Message-ID: <1398773350-7293-7-git-send-email-Frank.Li@freescale.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0242.outbound.protection.outlook.com ([207.46.163.242]:1195
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752160AbaD2NfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 09:35:12 -0400
In-Reply-To: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>

The iMX6 gigabit FEC does not support half-duplex gigabit operation.
Phys attacked to the FEC may support this, and we currently do nothing
to disable this feature.  This may result in an invalid configuration.
Mask out phy support for gigabit half-duplex operation.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1c84f3a..d9109ac 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1316,6 +1316,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	/* mask with MAC supported features */
 	if (id_entry->driver_data & FEC_QUIRK_HAS_GBIT) {
 		phy_dev->supported &= PHY_GBIT_FEATURES;
+		phy_dev->supported &= ~SUPPORTED_1000baseT_Half;
 #if !defined(CONFIG_M5272)
 		phy_dev->supported |= SUPPORTED_Pause;
 #endif
-- 
1.7.8
