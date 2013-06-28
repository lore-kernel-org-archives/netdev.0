From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH RFC net-next v1 1/1] net: fec: Fix RMON registers on imx6
Date: Fri, 28 Jun 2013 16:07:55 +0100
Message-ID: <1372432075-11629-1-git-send-email-jim_baxter@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com>
Cc: Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>,
	Joe Perches <joe@perches.com>, Chris Healy <cphealy@gmail.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:39911 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab3F1PID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 11:08:03 -0400
In-Reply-To: <Jim Baxter <jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 38ae92d "fec: Add support for reading
RMON registers" causes the imx6Q to crash.

This fixes it and clears it using the MIB Control
Register's MIB_CLEAR bit.

Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index ed6180e..a1f0413 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -607,8 +607,12 @@ fec_restart(struct net_device *ndev, int duplex)
 #ifndef CONFIG_M5272
 	/* Disable, clear, and enable the MIB */
 	writel(1 << 31, fep->hwp + FEC_MIB_CTRLSTAT);
-	for (i = RMON_T_DROP; i < IEEE_R_OCTETS_OK; i++)
-		writel(0, fep->hwp + i);
+	if (strcmp(id_entry->name, "imx6q-fec") == 0) {
+		writel(1 << 29, fep->hwp + FEC_MIB_CTRLSTAT);
+	} else {
+		for (i = RMON_T_DROP; i < IEEE_R_OCTETS_OK; i++)
+			writel(0, fep->hwp + i);
+	}
 	writel(0, fep->hwp + FEC_MIB_CTRLSTAT);
 #endif
 
-- 
1.7.10.4
