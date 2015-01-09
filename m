From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH 1/2] NFC: pn544: GPIO access that may sleep
Date: Fri,  9 Jan 2015 14:02:16 +0200
Message-ID: <1420804937-10787-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	Clement Perrochaud <clement.perrochaud@nxp.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gpio_set_value was replaced with gpio_set_value_cansleep in order
to allow GPIO access that may sleep. This is particularelly useful
when GPIO is accessed using busses like I2C, SPI, USB

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 drivers/nfc/pn544/i2c.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/nfc/pn544/i2c.c b/drivers/nfc/pn544/i2c.c
index fc02e8d..5f4b9c1 100644
--- a/drivers/nfc/pn544/i2c.c
+++ b/drivers/nfc/pn544/i2c.c
@@ -195,18 +195,18 @@ static void pn544_hci_i2c_platform_init(struct pn544_i2c_phy *phy)
 	nfc_info(&phy->i2c_dev->dev, "Detecting nfc_en polarity\n");
 
 	/* Disable fw download */
-	gpio_set_value(phy->gpio_fw, 0);
+	gpio_set_value_cansleep(phy->gpio_fw, 0);
 
 	for (polarity = 0; polarity < 2; polarity++) {
 		phy->en_polarity = polarity;
 		retry = 3;
 		while (retry--) {
 			/* power off */
-			gpio_set_value(phy->gpio_en, !phy->en_polarity);
+			gpio_set_value_cansleep(phy->gpio_en, !phy->en_polarity);
 			usleep_range(10000, 15000);
 
 			/* power on */
-			gpio_set_value(phy->gpio_en, phy->en_polarity);
+			gpio_set_value_cansleep(phy->gpio_en, phy->en_polarity);
 			usleep_range(10000, 15000);
 
 			/* send reset */
@@ -225,13 +225,13 @@ static void pn544_hci_i2c_platform_init(struct pn544_i2c_phy *phy)
 		"Could not detect nfc_en polarity, fallback to active high\n");
 
 out:
-	gpio_set_value(phy->gpio_en, !phy->en_polarity);
+	gpio_set_value_cansleep(phy->gpio_en, !phy->en_polarity);
 }
 
 static void pn544_hci_i2c_enable_mode(struct pn544_i2c_phy *phy, int run_mode)
 {
-	gpio_set_value(phy->gpio_fw, run_mode == PN544_FW_MODE ? 1 : 0);
-	gpio_set_value(phy->gpio_en, phy->en_polarity);
+	gpio_set_value_cansleep(phy->gpio_fw, run_mode == PN544_FW_MODE ? 1 : 0);
+	gpio_set_value_cansleep(phy->gpio_en, phy->en_polarity);
 	usleep_range(10000, 15000);
 
 	phy->run_mode = run_mode;
@@ -254,14 +254,14 @@ static void pn544_hci_i2c_disable(void *phy_id)
 {
 	struct pn544_i2c_phy *phy = phy_id;
 
-	gpio_set_value(phy->gpio_fw, 0);
-	gpio_set_value(phy->gpio_en, !phy->en_polarity);
+	gpio_set_value_cansleep(phy->gpio_fw, 0);
+	gpio_set_value_cansleep(phy->gpio_en, !phy->en_polarity);
 	usleep_range(10000, 15000);
 
-	gpio_set_value(phy->gpio_en, phy->en_polarity);
+	gpio_set_value_cansleep(phy->gpio_en, phy->en_polarity);
 	usleep_range(10000, 15000);
 
-	gpio_set_value(phy->gpio_en, !phy->en_polarity);
+	gpio_set_value_cansleep(phy->gpio_en, !phy->en_polarity);
 	usleep_range(10000, 15000);
 
 	phy->powered = 0;
-- 
1.9.1
