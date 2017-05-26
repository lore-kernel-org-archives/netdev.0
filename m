From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/3] net: dsa: mv88e6xxx: rename PHY PPU functions
Date: Fri, 26 May 2017 18:03:07 -0400
Message-ID: <20170526220307.23503-4-vivien.didelot@savoirfairelinux.com>
References: <20170526220307.23503-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526220307.23503-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Respect the implicit naming convention used in all register sets
specific files, by renaming the mv88e6xxx_ppu_* functions with the
mv88e6xxx_phy_* prefix.

This is simply a s/xxx_ppu/xxx_phy_ppu/ substitution.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/phy.c | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/phy.c b/drivers/net/dsa/mv88e6xxx/phy.c
index 19e0128257e5..d47a6e08d88c 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.c
+++ b/drivers/net/dsa/mv88e6xxx/phy.c
@@ -116,7 +116,7 @@ int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
 	return err;
 }
 
-static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
+static int mv88e6xxx_phy_ppu_disable(struct mv88e6xxx_chip *chip)
 {
 	if (!chip->info->ops->ppu_disable)
 		return 0;
@@ -124,7 +124,7 @@ static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 	return chip->info->ops->ppu_disable(chip);
 }
 
-static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
+static int mv88e6xxx_phy_ppu_enable(struct mv88e6xxx_chip *chip)
 {
 	if (!chip->info->ops->ppu_enable)
 		return 0;
@@ -132,7 +132,7 @@ static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
 	return chip->info->ops->ppu_enable(chip);
 }
 
-static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
+static void mv88e6xxx_phy_ppu_reenable_work(struct work_struct *ugly)
 {
 	struct mv88e6xxx_chip *chip;
 
@@ -141,7 +141,7 @@ static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
 	mutex_lock(&chip->reg_lock);
 
 	if (mutex_trylock(&chip->ppu_mutex)) {
-		if (mv88e6xxx_ppu_enable(chip) == 0)
+		if (mv88e6xxx_phy_ppu_enable(chip) == 0)
 			chip->ppu_disabled = 0;
 		mutex_unlock(&chip->ppu_mutex);
 	}
@@ -149,14 +149,14 @@ static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
 	mutex_unlock(&chip->reg_lock);
 }
 
-static void mv88e6xxx_ppu_reenable_timer(unsigned long _ps)
+static void mv88e6xxx_phy_ppu_reenable_timer(unsigned long _ps)
 {
 	struct mv88e6xxx_chip *chip = (void *)_ps;
 
 	schedule_work(&chip->ppu_work);
 }
 
-static int mv88e6xxx_ppu_access_get(struct mv88e6xxx_chip *chip)
+static int mv88e6xxx_phy_ppu_access_get(struct mv88e6xxx_chip *chip)
 {
 	int ret;
 
@@ -168,7 +168,7 @@ static int mv88e6xxx_ppu_access_get(struct mv88e6xxx_chip *chip)
 	 * it.
 	 */
 	if (!chip->ppu_disabled) {
-		ret = mv88e6xxx_ppu_disable(chip);
+		ret = mv88e6xxx_phy_ppu_disable(chip);
 		if (ret < 0) {
 			mutex_unlock(&chip->ppu_mutex);
 			return ret;
@@ -182,22 +182,22 @@ static int mv88e6xxx_ppu_access_get(struct mv88e6xxx_chip *chip)
 	return ret;
 }
 
-static void mv88e6xxx_ppu_access_put(struct mv88e6xxx_chip *chip)
+static void mv88e6xxx_phy_ppu_access_put(struct mv88e6xxx_chip *chip)
 {
 	/* Schedule a timer to re-enable the PHY polling unit. */
 	mod_timer(&chip->ppu_timer, jiffies + msecs_to_jiffies(10));
 	mutex_unlock(&chip->ppu_mutex);
 }
 
-static void mv88e6xxx_ppu_state_init(struct mv88e6xxx_chip *chip)
+static void mv88e6xxx_phy_ppu_state_init(struct mv88e6xxx_chip *chip)
 {
 	mutex_init(&chip->ppu_mutex);
-	INIT_WORK(&chip->ppu_work, mv88e6xxx_ppu_reenable_work);
-	setup_timer(&chip->ppu_timer, mv88e6xxx_ppu_reenable_timer,
+	INIT_WORK(&chip->ppu_work, mv88e6xxx_phy_ppu_reenable_work);
+	setup_timer(&chip->ppu_timer, mv88e6xxx_phy_ppu_reenable_timer,
 		    (unsigned long)chip);
 }
 
-static void mv88e6xxx_ppu_state_destroy(struct mv88e6xxx_chip *chip)
+static void mv88e6xxx_phy_ppu_state_destroy(struct mv88e6xxx_chip *chip)
 {
 	del_timer_sync(&chip->ppu_timer);
 }
@@ -207,10 +207,10 @@ int mv88e6185_phy_ppu_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 {
 	int err;
 
-	err = mv88e6xxx_ppu_access_get(chip);
+	err = mv88e6xxx_phy_ppu_access_get(chip);
 	if (!err) {
 		err = mv88e6xxx_read(chip, addr, reg, val);
-		mv88e6xxx_ppu_access_put(chip);
+		mv88e6xxx_phy_ppu_access_put(chip);
 	}
 
 	return err;
@@ -221,10 +221,10 @@ int mv88e6185_phy_ppu_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 {
 	int err;
 
-	err = mv88e6xxx_ppu_access_get(chip);
+	err = mv88e6xxx_phy_ppu_access_get(chip);
 	if (!err) {
 		err = mv88e6xxx_write(chip, addr, reg, val);
-		mv88e6xxx_ppu_access_put(chip);
+		mv88e6xxx_phy_ppu_access_put(chip);
 	}
 
 	return err;
@@ -233,16 +233,16 @@ int mv88e6185_phy_ppu_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip)
 {
 	if (chip->info->ops->ppu_enable && chip->info->ops->ppu_disable)
-		mv88e6xxx_ppu_state_init(chip);
+		mv88e6xxx_phy_ppu_state_init(chip);
 }
 
 void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip)
 {
 	if (chip->info->ops->ppu_enable && chip->info->ops->ppu_disable)
-		mv88e6xxx_ppu_state_destroy(chip);
+		mv88e6xxx_phy_ppu_state_destroy(chip);
 }
 
 int mv88e6xxx_phy_setup(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_ppu_enable(chip);
+	return mv88e6xxx_phy_ppu_enable(chip);
 }
-- 
2.13.0
