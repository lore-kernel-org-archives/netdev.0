From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 3/3] net: dsa: mv88e6xxx: specify ageing time limits
Date: Wed, 15 Mar 2017 15:53:50 -0400
Message-ID: <20170315195350.11059-4-vivien.didelot@savoirfairelinux.com>
References: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cobham <jcobham@questertangent.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that DSA has ageing time limits, specify them when registering a
switch so that out-of-range values are handled correctly by the core.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reported-by: Jason Cobham <jcobham@questertangent.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 3354f99df378..2bca297d9296 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -4253,6 +4253,8 @@ static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip)
 
 	ds->priv = chip;
 	ds->ops = &mv88e6xxx_switch_ops;
+	ds->ageing_time_min = chip->info->age_time_coeff;
+	ds->ageing_time_max = chip->info->age_time_coeff * U8_MAX;
 
 	dev_set_drvdata(dev, ds);
 
-- 
2.12.0
