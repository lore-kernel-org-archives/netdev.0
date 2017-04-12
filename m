From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH v2 1/3] mfd: max8998: Remove CONFIG_OF around max8998_dt_match
Date: Tue, 11 Apr 2017 21:41:54 -0700
Message-ID: <20170412044156.17351-2-f.fainelli@gmail.com>
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
CONFIG_OF is disabled which will properly take care of having the compiler
eliminate the variable. To avoid more #ifdef/#else, just always make the match
table available.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/mfd/max8998.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/mfd/max8998.c b/drivers/mfd/max8998.c
index 4c33b8063bc3..372f681ec1bb 100644
--- a/drivers/mfd/max8998.c
+++ b/drivers/mfd/max8998.c
@@ -129,14 +129,12 @@ int max8998_update_reg(struct i2c_client *i2c, u8 reg, u8 val, u8 mask)
 }
 EXPORT_SYMBOL(max8998_update_reg);
 
-#ifdef CONFIG_OF
 static const struct of_device_id max8998_dt_match[] = {
 	{ .compatible = "maxim,max8998", .data = (void *)TYPE_MAX8998 },
 	{ .compatible = "national,lp3974", .data = (void *)TYPE_LP3974 },
 	{ .compatible = "ti,lp3974", .data = (void *)TYPE_LP3974 },
 	{},
 };
-#endif
 
 /*
  * Only the common platform data elements for max8998 are parsed here from the
-- 
2.9.3
