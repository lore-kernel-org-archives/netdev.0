From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH net-next v1 1/1] net: fec: Fix RMON registers on imx6
Date: Mon,  1 Jul 2013 11:31:59 +0100
Message-ID: <1372674719-6525-1-git-send-email-jim_baxter@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com>
Cc: Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>,
	Joe Perches <joe@perches.com>, Chris Healy <cphealy@gmail.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:46221 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098Ab3GAKcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 06:32:08 -0400
In-Reply-To: <Jim Baxter <jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 38ae92d "fec: Add support for reading
RMON registers" causes the imx6Q to crash.

This fixes it by only enabling the RMON registers, the
registers are already cleared by the MAC being reset.

Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
---
Change v1 to v2
Removed per processor change and just set bit 31 to 0.

 drivers/net/ethernet/freescale/fec_main.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index ed6180e..c772df1 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -606,10 +606,7 @@ fec_restart(struct net_device *ndev, int duplex)
 
 #ifndef CONFIG_M5272
 	/* Disable, clear, and enable the MIB */
-	writel(1 << 31, fep->hwp + FEC_MIB_CTRLSTAT);
-	for (i = RMON_T_DROP; i < IEEE_R_OCTETS_OK; i++)
-		writel(0, fep->hwp + i);
-	writel(0, fep->hwp + FEC_MIB_CTRLSTAT);
+	writel(0 << 31, fep->hwp + FEC_MIB_CTRLSTAT);
 #endif
 
 	/* And last, enable the transmit and receive processing */
-- 
1.7.10.4
