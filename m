From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/5] net: phy: bcm7xxx: only show PHY revision once
Date: Tue, 11 Nov 2014 14:55:10 -0800
Message-ID: <1415746514-11189-2-git-send-email-f.fainelli@gmail.com>
References: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:42548 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349AbaKKWzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 17:55:22 -0500
Received: by mail-pd0-f179.google.com with SMTP id g10so10997506pdj.38
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 14:55:21 -0800 (PST)
In-Reply-To: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcm7xxx_28nm_config_init() can be called as frequently as needed by the
PHY library upon suspend/resume cycles and interface bring up/down, just
print the PHY revision once and for all in order not to spam kernel
logs.

Fixes: d8ebfed3f11b ("net: phy: bcm7xxx: utilize PHY revision in config_init")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 1d211d369039..25b07a4d31f8 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -200,7 +200,8 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 	u8 patch = PHY_BRCM_7XXX_PATCH(phydev->dev_flags);
 	int ret = 0;
 
-	dev_info(&phydev->dev, "PHY revision: 0x%02x, patch: %d\n", rev, patch);
+	pr_info_once("%s: %s PHY revision: 0x%02x, patch: %d\n",
+		     dev_name(&phydev->dev), phydev->drv->name, rev, patch);
 
 	switch (rev) {
 	case 0xa0:
-- 
1.9.1
