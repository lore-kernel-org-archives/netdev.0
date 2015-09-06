From: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
Subject: [PATCH] net: stmmac: Use msleep rather then udelay for reset delay
Date: Sun,  6 Sep 2015 17:50:59 +0200
Message-ID: <1441554659-8419-1-git-send-email-sjoerd.simons@collabora.co.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The reset delays used for stmmac are in the order of 10ms to 1 second,
which is far too long for udelay usage, so switch to using msleep.

Practically this fixes the PHY not being reliably detected in some cases
as udelay wouldn't actually delay for long enough to let the phy
reliably be reset.

Signed-off-by: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
---

 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index b735fa2..17fa588 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -161,11 +161,16 @@ int stmmac_mdio_reset(struct mii_bus *bus)
 
 		if (!gpio_request(reset_gpio, "mdio-reset")) {
 			gpio_direction_output(reset_gpio, active_low ? 1 : 0);
-			udelay(data->delays[0]);
+			if (data->delays[0])
+				msleep((data->delays[0] + 999) / 1000);
+
 			gpio_set_value(reset_gpio, active_low ? 0 : 1);
-			udelay(data->delays[1]);
+			if (data->delays[1])
+				msleep((data->delays[1] + 999) / 1000);
+
 			gpio_set_value(reset_gpio, active_low ? 1 : 0);
-			udelay(data->delays[2]);
+			if (data->delays[2])
+				msleep((data->delays[2] + 999) / 1000);
 		}
 	}
 #endif
-- 
2.5.1
