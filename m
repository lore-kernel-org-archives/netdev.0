From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] broadcom: Fix &&/|| confusion in bcm54xx_adjust_rxrefclk()
Date: Wed, 30 Dec 2009 17:43:06 +0100
Message-ID: <4B3B831A.507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, mcarlson@broadcom.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752640AbZL3QkA@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This always evaluates to true.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/phy/broadcom.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index c13cf64..33c4b12 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -331,8 +331,8 @@ static void bcm54xx_adjust_rxrefclk(struct phy_device *phydev)
 	bool clk125en = true;
 
 	/* Abort if we are using an untested phy. */
-	if (BRCM_PHY_MODEL(phydev) != PHY_ID_BCM57780 ||
-	    BRCM_PHY_MODEL(phydev) != PHY_ID_BCM50610 ||
+	if (BRCM_PHY_MODEL(phydev) != PHY_ID_BCM57780 &&
+	    BRCM_PHY_MODEL(phydev) != PHY_ID_BCM50610 &&
 	    BRCM_PHY_MODEL(phydev) != PHY_ID_BCM50610M)
 		return;
 
