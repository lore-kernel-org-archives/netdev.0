From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH] net: phy: micrel: don't do clock-mode-select if we got NULL clock
Date: Thu, 23 Apr 2015 15:37:11 +0200
Message-ID: <1429796231-8542-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<johan@kernel.org>, Niklas Cassel <niklass@axis.com>
To: <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:36577 "EHLO
	bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbbDWNhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 09:37:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Niklas Cassel <niklass@axis.com>
---
 drivers/net/phy/micrel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 1190fd8..a422036 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -548,7 +548,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	}
 
 	clk = devm_clk_get(&phydev->dev, "rmii-ref");
-	if (!IS_ERR(clk)) {
+	if (!IS_ERR_OR_NULL(clk)) {
 		unsigned long rate = clk_get_rate(clk);
 		bool rmii_ref_clk_sel_25_mhz;
 
-- 
2.1.4
