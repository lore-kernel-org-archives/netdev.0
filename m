From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 3/3] net: phy: bcm7xxx: remove suspend callback for 28nm PHYs
Date: Thu, 14 Aug 2014 16:52:53 -0700
Message-ID: <1408060373-5996-4-git-send-email-f.fainelli@gmail.com>
References: <1408060373-5996-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:40959 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbaHNXxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 19:53:19 -0400
Received: by mail-pa0-f51.google.com with SMTP id ey11so2511261pad.38
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 16:53:18 -0700 (PDT)
In-Reply-To: <1408060373-5996-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BCM7xxx internal Gigabit PHY on 28nm process do not need anything
special to be done during suspend, remove the suspend callback since it
might be harmful rather than useful. While at it, update the comment
above bcm7xxx_suspend() to reflect that it applies only to 40nm and 65nm
process PHY devices.

Fixes: b560a58c45c6 ("net: phy: add Broadcom BCM7xxx internal PHY driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index a8ca03ff4f1e..fdce1ea28790 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -229,7 +229,7 @@ static int bcm7xxx_config_init(struct phy_device *phydev)
 }
 
 /* Workaround for putting the PHY in IDDQ mode, required
- * for all BCM7XXX PHYs
+ * for all BCM7XXX 40nm and 65nm PHYs
  */
 static int bcm7xxx_suspend(struct phy_device *phydev)
 {
@@ -274,7 +274,6 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.config_init	= bcm7xxx_28nm_afe_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
-	.suspend	= bcm7xxx_suspend,
 	.resume		= bcm7xxx_28nm_resume,
 	.driver		= { .owner = THIS_MODULE },
 }, {
@@ -287,7 +286,6 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.config_init	= bcm7xxx_28nm_afe_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
-	.suspend	= bcm7xxx_suspend,
 	.resume		= bcm7xxx_28nm_resume,
 	.driver		= { .owner = THIS_MODULE },
 }, {
@@ -300,7 +298,6 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.config_init	= bcm7xxx_28nm_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
-	.suspend	= bcm7xxx_suspend,
 	.resume		= bcm7xxx_28nm_afe_config_init,
 	.driver		= { .owner = THIS_MODULE },
 }, {
-- 
1.9.1
