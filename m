From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 10/22] net: phy: micrel: refactor led-mode error handling
Date: Tue, 11 Nov 2014 18:37:28 +0100
Message-ID: <1415727460-20417-11-git-send-email-johan@kernel.org>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:63318 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647AbaKKRir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 12:38:47 -0500
In-Reply-To: <1415727460-20417-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor led-mode error handling.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 1b3985cdc64c..ec9ce35e934b 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -179,14 +179,19 @@ static int kszphy_setup_led(struct phy_device *phydev,
 	}
 
 	temp = phy_read(phydev, reg);
-	if (temp < 0)
-		return temp;
+	if (temp < 0) {
+		rc = temp;
+		goto out;
+	}
 
 	temp &= ~(3 << shift);
 	temp |= val << shift;
 	rc = phy_write(phydev, reg, temp);
+out:
+	if (rc < 0)
+		dev_err(&phydev->dev, "failed to set led mode\n");
 
-	return rc < 0 ? rc : 0;
+	return rc;
 }
 
 /* Disable PHY address 0 as the broadcast address, so that it can be used as a
@@ -223,9 +228,7 @@ static int ksz8021_config_init(struct phy_device *phydev)
 {
 	int rc;
 
-	rc = kszphy_setup_led(phydev, 0x1f, 4);
-	if (rc)
-		dev_err(&phydev->dev, "failed to set led mode\n");
+	kszphy_setup_led(phydev, 0x1f, 4);
 
 	rc = ksz_config_flags(phydev);
 	if (rc < 0)
@@ -240,9 +243,7 @@ static int ks8051_config_init(struct phy_device *phydev)
 {
 	int rc;
 
-	rc = kszphy_setup_led(phydev, 0x1f, 4);
-	if (rc)
-		dev_err(&phydev->dev, "failed to set led mode\n");
+	kszphy_setup_led(phydev, 0x1f, 4);
 
 	rc = ksz_config_flags(phydev);
 	return rc < 0 ? rc : 0;
-- 
2.0.4
