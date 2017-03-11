From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 03/17] net: dsa: mv88e6xxx: add ATU setup helper
Date: Sat, 11 Mar 2017 16:12:49 -0500
Message-ID: <20170311211303.24560-4-vivien.didelot@savoirfairelinux.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:55024 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755340AbdCKVPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 16:15:04 -0500
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the configuration of the default ageing time in a new
mv88e6xxx_atu_setup function.

That function will be extended later to contain all ATU related
configuration bits.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b228b8491afc..0ad8200f3321 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1306,6 +1306,11 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 		netdev_err(ds->ports[port].netdev, "failed to update state\n");
 }
 
+static int mv88e6xxx_atu_setup(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_g1_atu_set_age_time(chip, 300000);
+}
+
 static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
@@ -2756,10 +2761,6 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	err = mv88e6xxx_g1_atu_set_age_time(chip, 300000);
-	if (err)
-		return err;
-
 	/* Clear all ATU entries */
 	err = _mv88e6xxx_atu_flush(chip, 0, true);
 	if (err)
@@ -2845,6 +2846,10 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 			goto unlock;
 	}
 
+	err = mv88e6xxx_atu_setup(chip);
+	if (err)
+		goto unlock;
+
 	/* Some generations have the configuration of sending reserved
 	 * management frames to the CPU in global2, others in
 	 * global1. Hence it does not fit the two setup functions
-- 
2.12.0
