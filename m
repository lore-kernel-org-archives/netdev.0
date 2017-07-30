From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v2 net-next 1/4] net: dsa: lan9303: Fix lan9303_detect_phy_setup() for MDIO
Date: Sun, 30 Jul 2017 19:58:53 +0200
Message-ID: <20170730175856.4784-2-privat@egil-hjelmeland.no>
References: <20170730175856.4784-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170730175856.4784-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handle that MDIO read with no response return 0xffff.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/lan9303-core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index cd76e61f1fca..9d0ab77edb4a 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -427,6 +427,7 @@ static int lan9303_detect_phy_setup(struct lan9303 *chip)
 	 * Special reg 18 of phy 3 reads as 0x0000, if 'phy_addr_sel_strap' is 0
 	 * and the IDs are 0-1-2, else it contains something different from
 	 * 0x0000, which means 'phy_addr_sel_strap' is 1 and the IDs are 1-2-3.
+	 * 0xffff is returned on MDIO read with no response.
 	 */
 	reg = lan9303_port_phy_reg_read(chip, 3, MII_LAN911X_SPECIAL_MODES);
 	if (reg < 0) {
@@ -434,7 +435,7 @@ static int lan9303_detect_phy_setup(struct lan9303 *chip)
 		return reg;
 	}
 
-	if (reg != 0)
+	if ((reg != 0) && (reg != 0xffff))
 		chip->phy_addr_sel_strap = 1;
 	else
 		chip->phy_addr_sel_strap = 0;
-- 
2.11.0
