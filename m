From: Emil Goode <emilgoode@gmail.com>
Subject: [PATCH] stmmac: Remove spin_lock call in stmmac_get_pauseparam()
Date: Mon,  2 Jun 2014 11:30:50 +0200
Message-ID: <1401701450-1203-1-git-send-email-emilgoode@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, Emil Goode <emilgoode@gmail.com>
To: Yang Wei <Wei.Yang@windriver.com>,
	David Miller <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patch removed unnecessary spin_lock/unlock calls
in ethtool_ops callback functions. In the second and final version
of the patch one spin_lock call was left behind.

commit cab6715c3e8029e98b0b5d4056ceda007c0f6380
Author: Yang Wei <Wei.Yang@windriver.com>
Date:   Sun May 25 09:53:44 2014 +0800

    net: driver: stmicro: Remove some useless the lock protection

This introduced the following sparse warning:

drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c:424:1: warning:
	context imbalance in 'stmmac_get_pauseparam' -
	different lock contexts for basic block

Signed-off-by: Emil Goode <emilgoode@gmail.com>
---
Hello,

Some spin_lock/unlock calls where also left behind in
stmmac_ethtool_setsettings(), I'm not sure if it was intentional?

Best regards,

Emil Goode

 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 7892666..c62e67f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -429,8 +429,6 @@ stmmac_get_pauseparam(struct net_device *netdev,
 	if (priv->pcs)	/* FIXME */
 		return;
 
-	spin_lock(&priv->lock);
-
 	pause->rx_pause = 0;
 	pause->tx_pause = 0;
 	pause->autoneg = priv->phydev->autoneg;
-- 
1.7.10.4
