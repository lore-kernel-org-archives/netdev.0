From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/5] net: dsa: bcm_sf2: Utilize BRCM_PSEUDO_PHY_ADDR
Date: Wed, 10 Jun 2015 18:08:01 -0700
Message-ID: <1433984881-28781-6-git-send-email-f.fainelli@gmail.com>
References: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, hauke@hauke-m.de,
	zajec5@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:33194 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbbFKBJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 21:09:18 -0400
Received: by qkhg32 with SMTP id g32so33707891qkh.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 18:09:17 -0700 (PDT)
In-Reply-To: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Utilize the newly introduced BRCM_PSEUDO_PHY_ADDR constant from
brcmphy.h instead of open-coding the Broadcom Ethernet switches
pseudo-PHY address (30).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 103fde3da476..972982f8bea7 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -24,6 +24,7 @@
 #include <net/dsa.h>
 #include <linux/ethtool.h>
 #include <linux/if_bridge.h>
+#include <linux/brcmphy.h>
 
 #include "bcm_sf2.h"
 #include "bcm_sf2_regs.h"
@@ -697,7 +698,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	/* Include the pseudo-PHY address and the broadcast PHY address to
 	 * divert reads towards our workaround
 	 */
-	ds->phys_mii_mask |= ((1 << 30) | (1 << 0));
+	ds->phys_mii_mask |= ((1 << BRCM_PSEUDO_PHY_ADDR) | (1 << 0));
 
 	rev = reg_readl(priv, REG_SWITCH_REVISION);
 	priv->hw_params.top_rev = (rev >> SWITCH_TOP_REV_SHIFT) &
@@ -782,7 +783,7 @@ static int bcm_sf2_sw_phy_read(struct dsa_switch *ds, int addr, int regnum)
 	 */
 	switch (addr) {
 	case 0:
-	case 30:
+	case BRCM_PSEUDO_PHY_ADDR:
 		return bcm_sf2_sw_indir_rw(ds, 1, addr, regnum, 0);
 	default:
 		return 0xffff;
@@ -797,7 +798,7 @@ static int bcm_sf2_sw_phy_write(struct dsa_switch *ds, int addr, int regnum,
 	 */
 	switch (addr) {
 	case 0:
-	case 30:
+	case BRCM_PSEUDO_PHY_ADDR:
 		bcm_sf2_sw_indir_rw(ds, 0, addr, regnum, val);
 		break;
 	}
-- 
2.1.0
