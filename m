From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH v2 net 4/8] net: bcmgenet: power down internal phy if open or resume fails
Date: Thu,  9 Mar 2017 16:58:46 -0800
Message-ID: <20170310005850.10808-5-opendmb@gmail.com>
References: <20170310005850.10808-1-opendmb@gmail.com>
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310005850.10808-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the internal PHY is powered up during the open and resume
functions it should be powered back down if the functions fail.

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 99f8d9024633..475dc14931af 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2850,6 +2850,8 @@ static int bcmgenet_open(struct net_device *dev)
 err_fini_dma:
 	bcmgenet_fini_dma(priv);
 err_clk_disable:
+	if (priv->internal_phy)
+		bcmgenet_power_down(priv, GENET_POWER_PASSIVE);
 	clk_disable_unprepare(priv->clk);
 	return ret;
 }
@@ -3551,6 +3553,8 @@ static int bcmgenet_resume(struct device *d)
 	return 0;
 
 out_clk_disable:
+	if (priv->internal_phy)
+		bcmgenet_power_down(priv, GENET_POWER_PASSIVE);
 	clk_disable_unprepare(priv->clk);
 	return ret;
 }
-- 
2.11.1
