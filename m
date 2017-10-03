From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: dsa: lan9303: make functions lan9303_mdio_phy_{read|write} static
Date: Tue,  3 Oct 2017 11:39:18 +0100
Message-ID: <20171003103918.26934-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The functions lan9303_mdio_phy_write and lan9303_mdio_phy_read are local
to the source and do not need to be in global scope, so make them static.

Cleans up sparse warnings:
symbol 'lan9303_mdio_phy_write' was not declared. Should it be static?
symbol 'lan9303_mdio_phy_read' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/dsa/lan9303_mdio.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/lan9303_mdio.c b/drivers/net/dsa/lan9303_mdio.c
index fc16668a487f..0bc56b9900f9 100644
--- a/drivers/net/dsa/lan9303_mdio.c
+++ b/drivers/net/dsa/lan9303_mdio.c
@@ -67,14 +67,15 @@ static int lan9303_mdio_read(void *ctx, uint32_t reg, uint32_t *val)
 	return 0;
 }
 
-int lan9303_mdio_phy_write(struct lan9303 *chip, int phy, int reg, u16 val)
+static int lan9303_mdio_phy_write(struct lan9303 *chip, int phy, int reg,
+				  u16 val)
 {
 	struct lan9303_mdio *sw_dev = dev_get_drvdata(chip->dev);
 
 	return mdiobus_write_nested(sw_dev->device->bus, phy, reg, val);
 }
 
-int lan9303_mdio_phy_read(struct lan9303 *chip, int phy,  int reg)
+static int lan9303_mdio_phy_read(struct lan9303 *chip, int phy,  int reg)
 {
 	struct lan9303_mdio *sw_dev = dev_get_drvdata(chip->dev);
 
-- 
2.14.1
