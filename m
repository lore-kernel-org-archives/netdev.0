From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: debug ATU Age Time
Date: Mon, 13 Mar 2017 15:20:43 -0400
Message-ID: <20170313192043.12478-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cobham <jcobham@questertangent.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ATU ageing time value programmed in the switch is rounded up to the
nearest multiple of its coefficient (variable depending on the model.)

Add a debug message to inform the user about the exact programmed value.

On 6352, "brctl setageing br0 18" gives "AgeTime set to 0x01 (15000 ms)"
while on 6390 we get "AgeTime set to 0x05 (18750 ms)".

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index f6cd3c939da4..bac34737b096 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -65,7 +65,14 @@ int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
 	val &= ~0xff0;
 	val |= age_time << 4;
 
-	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
+	if (err)
+		return err;
+
+	dev_dbg(chip->dev, "AgeTime set to 0x%02x (%d ms)\n", age_time,
+		age_time * coeff);
+
+	return 0;
 }
 
 /* Offset 0x0B: ATU Operation Register */
-- 
2.12.0
