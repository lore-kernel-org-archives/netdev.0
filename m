From: Hubert Chaumette <hchaumette@adeneo-embedded.com>
Subject: [PATCH] net/phy: micrel: fix bugged test on device tree loading for ksz9021
Date: Tue, 22 Apr 2014 15:01:04 +0200
Message-ID: <1398171664-32662-1-git-send-email-hchaumette@adeneo-embedded.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In ksz9021_load_values_from_of() val2 to val4 aren't tested against their
initialization value.
This causes the test to always succeed, and this value to be used as if it
was loaded from the devicetree instead of being ignored, in case of a
missing/invalid property in the ethernet OF device node.
As a result, the value "0" is written to the relevant registers.

Change the conditions to test against the right initialization value.

Signed-off-by: Hubert Chaumette <hchaumette@adeneo-embedded.com>
---
 drivers/net/phy/micrel.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index df56b26..8c4b1b2 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -205,13 +205,13 @@ static int ksz9021_load_values_from_of(struct phy_device *phydev,
 	if (val1 != -1)
 		newval = ((newval & 0xfff0) | ((val1 / PS_TO_REG) & 0xf) << 0);
 
-	if (val2 != -1)
+	if (val2 != -2)
 		newval = ((newval & 0xff0f) | ((val2 / PS_TO_REG) & 0xf) << 4);
 
-	if (val3 != -1)
+	if (val3 != -3)
 		newval = ((newval & 0xf0ff) | ((val3 / PS_TO_REG) & 0xf) << 8);
 
-	if (val4 != -1)
+	if (val4 != -4)
 		newval = ((newval & 0x0fff) | ((val4 / PS_TO_REG) & 0xf) << 12);
 
 	return kszphy_extended_write(phydev, reg, newval);
-- 
1.9.2
