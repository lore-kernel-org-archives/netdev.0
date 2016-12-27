From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 08/16] net: mvpp2: adapt mvpp2_defaults_set() to PPv2.2
Date: Tue, 27 Dec 2016 17:54:29 +0100
Message-ID: <1482857677-16166-9-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482857677-16166-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36741 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933173AbcL0Qyr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 11:54:47 -0500
In-Reply-To: <1482857677-16166-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit modifies the mvpp2_defaults_set() function to not do the
loopback and FIFO threshold initialization, which are not needed for
PPv2.2.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 8fc818d..23f2368 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -4205,16 +4205,18 @@ static void mvpp2_defaults_set(struct mvpp2_port *port)
 {
 	int tx_port_num, val, queue, ptxq, lrxq;
 
-	/* Configure port to loopback if needed */
-	if (port->flags & MVPP2_F_LOOPBACK)
-		mvpp2_port_loopback_set(port);
-
-	/* Update TX FIFO MIN Threshold */
-	val = readl(port->base + MVPP2_GMAC_PORT_FIFO_CFG_1_REG);
-	val &= ~MVPP2_GMAC_TX_FIFO_MIN_TH_ALL_MASK;
-	/* Min. TX threshold must be less than minimal packet length */
-	val |= MVPP2_GMAC_TX_FIFO_MIN_TH_MASK(64 - 4 - 2);
-	writel(val, port->base + MVPP2_GMAC_PORT_FIFO_CFG_1_REG);
+	if (port->priv->hw_version == MVPP21) {
+		/* Configure port to loopback if needed */
+		if (port->flags & MVPP2_F_LOOPBACK)
+			mvpp2_port_loopback_set(port);
+
+		/* Update TX FIFO MIN Threshold */
+		val = readl(port->base + MVPP2_GMAC_PORT_FIFO_CFG_1_REG);
+		val &= ~MVPP2_GMAC_TX_FIFO_MIN_TH_ALL_MASK;
+		/* Min. TX threshold must be less than minimal packet length */
+		val |= MVPP2_GMAC_TX_FIFO_MIN_TH_MASK(64 - 4 - 2);
+		writel(val, port->base + MVPP2_GMAC_PORT_FIFO_CFG_1_REG);
+	}
 
 	/* Disable Legacy WRR, Disable EJP, Release from reset */
 	tx_port_num = mvpp2_egress_port(port);
-- 
2.7.4
