From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH v2 2/3] net: macb: Remove CONFIG_OF around DT match table
Date: Tue, 11 Apr 2017 21:41:55 -0700
Message-ID: <20170412044156.17351-3-f.fainelli@gmail.com>
References: <20170412044156.17351-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Lee Jones <lee.jones@linaro.org>,
        Nicolas Ferre <nicolas.ferre@microchip.com>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
        devicetree@vger.kernel.org (open list:OPEN FIRMWARE AND FLATTENED
        DEVICE TREE)
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170412044156.17351-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A subsequent patch is going to make of_match_node() an inline stub when
CONFIG_OF is disabled, which will let the compiler eliminate unused variables.
In order not to clutter the code more, remove the CONFIG_OF #ifdef such that
macb_dt_ids and what it references are always defined.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 30606b11b128..01016e9525ee 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2811,7 +2811,6 @@ static int macb_init(struct platform_device *pdev)
 	return 0;
 }
 
-#if defined(CONFIG_OF)
 /* 1518 rounded up */
 #define AT91ETHER_MAX_RBUFF_SZ	0x600
 /* max number of receive buffers */
@@ -3215,7 +3214,6 @@ static const struct of_device_id macb_dt_ids[] = {
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, macb_dt_ids);
-#endif /* CONFIG_OF */
 
 static const struct macb_config default_gem_config = {
 	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO,
-- 
2.9.3
