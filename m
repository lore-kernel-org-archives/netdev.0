From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/3] net: phy: mdio-gpio: Handle phy_ignore_ta_mask
Date: Tue, 12 May 2015 10:33:26 -0700
Message-ID: <1431452006-3219-4-git-send-email-f.fainelli@gmail.com>
References: <1431442563-10218-1-git-send-email-bert@biot.com>
 <1431452006-3219-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jogo@openwrt.org, bert@biot.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36137 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933250AbbELRdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 13:33:54 -0400
Received: by pabsx10 with SMTP id sx10so20176037pab.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 10:33:54 -0700 (PDT)
In-Reply-To: <1431452006-3219-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update mdiobb_read() to read whether the PHY has a broken turn-around,
and if it does, ignore it to make the read succeeed.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio-bitbang.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
index daec9b05d168..61a543c788cc 100644
--- a/drivers/net/phy/mdio-bitbang.c
+++ b/drivers/net/phy/mdio-bitbang.c
@@ -165,8 +165,11 @@ static int mdiobb_read(struct mii_bus *bus, int phy, int reg)
 
 	ctrl->ops->set_mdio_dir(ctrl, 0);
 
-	/* check the turnaround bit: the PHY should be driving it to zero */
-	if (mdiobb_get_bit(ctrl) != 0) {
+	/* check the turnaround bit: the PHY should be driving it to zero, if this
+	 * PHY is listed in phy_ignore_ta_mask as having broken TA, skip that
+	 */
+	if (mdiobb_get_bit(ctrl) != 0 &&
+	    !(bus->phy_ignore_ta_mask & (1 << phy))) {
 		/* PHY didn't drive TA low -- flush any bits it
 		 * may be trying to send.
 		 */
-- 
2.1.0
