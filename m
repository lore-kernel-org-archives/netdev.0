From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next v2 2/7] net: mvpp2: remove RX queue group reset code
Date: Thu,  3 Aug 2017 10:41:56 +0200
Message-ID: <20170803084201.30305-3-thomas.petazzoni@free-electrons.com>
References: <20170803084201.30305-1-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        =?UTF-8?q?Miqu=C3=A8l=20Raynal?= <miquel.raynal@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:46634 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751352AbdHCIm2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 04:42:28 -0400
In-Reply-To: <20170803084201.30305-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RX queue group allocation is anyway re-done later in
mvpp2_port_init(), so resetting it in mvpp2_init() is not very useful,
and will be annoying as we are going to rework the RX queue group
allocation logic.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 17 -----------------
 1 file changed, 17 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 4b36a15..537d2b4 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6845,23 +6845,6 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 	/* Rx Fifo Init */
 	mvpp2_rx_fifo_init(priv);
 
-	/* Reset Rx queue group interrupt configuration */
-	for (i = 0; i < MVPP2_MAX_PORTS; i++) {
-		if (priv->hw_version == MVPP21) {
-			mvpp2_write(priv, MVPP21_ISR_RXQ_GROUP_REG(i),
-				    rxq_number);
-			continue;
-		} else {
-			u32 val;
-
-			val = (i << MVPP22_ISR_RXQ_GROUP_INDEX_GROUP_OFFSET);
-			mvpp2_write(priv, MVPP22_ISR_RXQ_GROUP_INDEX_REG, val);
-
-			val = (rxq_number << MVPP22_ISR_RXQ_SUB_GROUP_SIZE_OFFSET);
-			mvpp2_write(priv, MVPP22_ISR_RXQ_SUB_GROUP_CONFIG_REG, val);
-		}
-	}
-
 	if (priv->hw_version == MVPP21)
 		writel(MVPP2_EXT_GLOBAL_CTRL_DEFAULT,
 		       priv->lms_base + MVPP2_MNG_EXTENDED_GLOBAL_CTRL_REG);
-- 
2.9.4
