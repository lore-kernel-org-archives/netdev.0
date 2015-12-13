From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH net] ravb: Add disable 10base
Date: Mon, 14 Dec 2015 00:15:58 +0900
Message-ID: <1450019758-32710-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

Ethernet AVB does not support 10 Mbps transfer speed.

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's networking
tree.

 drivers/net/ethernet/renesas/ravb_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index b69e0c2..467d416 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -905,6 +905,9 @@ static int ravb_phy_init(struct net_device *ndev)
 		netdev_info(ndev, "limited PHY to 100Mbit/s\n");
 	}
 
+	/* 10BASE is not supported */
+	phydev->supported &= ~PHY_10BT_FEATURES;
+
 	netdev_info(ndev, "attached PHY %d (IRQ %d) to driver %s\n",
 		    phydev->addr, phydev->irq, phydev->drv->name);
 
-- 
1.9.1

