From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next] net: mvpp2: fix the packet size configuration for 10G
Date: Fri, 25 Aug 2017 15:24:46 +0200
Message-ID: <20170825132446.1130-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:41675 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932201AbdHYNZN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 09:25:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MVPP22_XLG_CTRL1_FRAMESIZELIMIT define is used as an offset, but is
defined as BIT(0). Updated its name to contains "OFFS" as in offset and
fix its value using the offset value, 0.

Reported-by: Stefan Chulski <stefanc@marvell.com>
Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Fixes: 76eb1b1de5b6 ("net: mvpp2: set maximum packet size for 10G ports")
---

Hi Dave,

This patch fixes a bug only present in net-next as it was introduced
recently.

Thanks!
Antoine

 drivers/net/ethernet/marvell/mvpp2.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 7fa251bf91ae..fea9ae5b70ba 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -367,7 +367,7 @@
 #define     MVPP22_XLG_CTRL0_RX_FLOW_CTRL_EN	BIT(7)
 #define     MVPP22_XLG_CTRL0_MIB_CNT_DIS	BIT(14)
 #define MVPP22_XLG_CTRL1_REG			0x104
-#define     MVPP22_XLG_CTRL1_FRAMESIZELIMIT	BIT(0)
+#define     MVPP22_XLG_CTRL1_FRAMESIZELIMIT_OFFS	0
 #define     MVPP22_XLG_CTRL1_FRAMESIZELIMIT_MASK	0x1fff
 #define MVPP22_XLG_CTRL3_REG			0x11c
 #define     MVPP22_XLG_CTRL3_MACMODESELECT_MASK	(7 << 13)
@@ -4669,7 +4669,7 @@ static inline void mvpp2_xlg_max_rx_size_set(struct mvpp2_port *port)
 	val =  readl(port->base + MVPP22_XLG_CTRL1_REG);
 	val &= ~MVPP22_XLG_CTRL1_FRAMESIZELIMIT_MASK;
 	val |= ((port->pkt_size - MVPP2_MH_SIZE) / 2) <<
-	       MVPP22_XLG_CTRL1_FRAMESIZELIMIT;
+	       MVPP22_XLG_CTRL1_FRAMESIZELIMIT_OFFS;
 	writel(val, port->base + MVPP22_XLG_CTRL1_REG);
 }
 
-- 
2.13.5
