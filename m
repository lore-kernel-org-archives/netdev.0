From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: modify the check of the flag of PHY_RESET in set_speed function
Date: Thu, 16 Jun 2016 14:08:29 +0800
Message-ID: <1394712342-15778-183-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In set_speed(), BMCR_RESET would be set when the flag of PHY_RESET
is set. Use BMCR_RESET to replace testing the flag of PHY_RESET.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 69d1bbfd..11178f9 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2872,7 +2872,7 @@ static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 		bmcr = BMCR_ANENABLE | BMCR_ANRESTART;
 	}
 
-	if (test_bit(PHY_RESET, &tp->flags))
+	if (test_and_clear_bit(PHY_RESET, &tp->flags))
 		bmcr |= BMCR_RESET;
 
 	if (tp->mii.supports_gmii)
@@ -2881,7 +2881,7 @@ static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 	r8152_mdio_write(tp, MII_ADVERTISE, anar);
 	r8152_mdio_write(tp, MII_BMCR, bmcr);
 
-	if (test_and_clear_bit(PHY_RESET, &tp->flags)) {
+	if (bmcr & BMCR_RESET) {
 		int i;
 
 		for (i = 0; i < 50; i++) {
-- 
2.4.11
