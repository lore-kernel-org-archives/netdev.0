From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 02/18] net: mvpp2: fix the synchronization module bypass macro name
Date: Mon, 24 Jul 2017 15:48:32 +0200
Message-ID: <20170724134848.19330-3-antoine.tenart@free-electrons.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47318 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753271AbdGXNuD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:50:03 -0400
In-Reply-To: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro defining the bit to toggle to bypass or not the
synchronization module is wrongly named. Writing 1 will disable bypass.
This patch s/MVPP22_CTRL4_SYNC_BYPASS/MVPP22_CTRL4_SYNC_BYPASS_DIS/.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index ee4ea195eb0b..1e592abc9067 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -339,7 +339,7 @@
 #define MVPP22_GMAC_CTRL_4_REG			0x90
 #define     MVPP22_CTRL4_EXT_PIN_GMII_SEL	BIT(0)
 #define     MVPP22_CTRL4_DP_CLK_SEL		BIT(5)
-#define     MVPP22_CTRL4_SYNC_BYPASS		BIT(6)
+#define     MVPP22_CTRL4_SYNC_BYPASS_DIS	BIT(6)
 #define     MVPP22_CTRL4_QSGMII_BYPASS_ACTIVE	BIT(7)
 
 /* Per-port XGMAC registers. PPv2.2 only, only for GOP port 0,
@@ -4195,7 +4195,7 @@ static void mvpp22_port_mii_set(struct mvpp2_port *port)
 	else
 		val &= ~MVPP22_CTRL4_EXT_PIN_GMII_SEL;
 	val &= ~MVPP22_CTRL4_DP_CLK_SEL;
-	val |= MVPP22_CTRL4_SYNC_BYPASS;
+	val |= MVPP22_CTRL4_SYNC_BYPASS_DIS;
 	val |= MVPP22_CTRL4_QSGMII_BYPASS_ACTIVE;
 	writel(val, port->base + MVPP22_GMAC_CTRL_4_REG);
 }
-- 
2.13.3
