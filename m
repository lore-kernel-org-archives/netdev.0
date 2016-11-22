From: =?UTF-8?Q?Daniel_Kr=c3=bcger?=
        <daniel.krueger@systec-electronic.com>
Subject: [PATCH] fec: Always write MAC address to controller register
Date: Tue, 22 Nov 2016 12:24:39 +0100
Message-ID: <038ccd3c-6d77-d9e1-92e1-c41572684812@systec-electronic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Alexander Stein <alexander.stein@systec-electronic.com>
To: Fugang Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:34501 "EHLO
        webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933003AbcKVLYn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 06:24:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On non-FEC_QUIRK_ENET_MAC types the MAC address needs to be set in FEC
during initialisation, if not done by bootloader already. Especially random
MACs or MAC addresses provided by kernel parameter must be set.

Signed-off-by: Daniel Krueger <daniel.krueger@systec-electronic.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 2a03857..ea32fda 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -902,14 +902,14 @@ fec_restart(struct net_device *ndev)
 	/*
 	 * enet-mac reset will reset mac address registers too,
 	 * so need to reconfigure it.
+	 * On non-FEC_QUIRK_ENET_MAC types it won't be reset,
+	 * but it must be configured once at least (especially random MACs).
 	 */
-	if (fep->quirks & FEC_QUIRK_ENET_MAC) {
-		memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
-		writel((__force u32)cpu_to_be32(temp_mac[0]),
-		       fep->hwp + FEC_ADDR_LOW);
-		writel((__force u32)cpu_to_be32(temp_mac[1]),
-		       fep->hwp + FEC_ADDR_HIGH);
-	}
+	memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
+	writel((__force u32)cpu_to_be32(temp_mac[0]),
+	       fep->hwp + FEC_ADDR_LOW);
+	writel((__force u32)cpu_to_be32(temp_mac[1]),
+	       fep->hwp + FEC_ADDR_HIGH);
 
 	/* Clear any outstanding interrupt. */
 	writel(0xffffffff, fep->hwp + FEC_IEVENT);
-- 
1.7.9.5
