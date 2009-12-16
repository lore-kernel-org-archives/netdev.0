From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] broadcom: bcm54xx_shadow_read() errors ignored in bcm54xx_adjust_rxrefclk()
Date: Wed, 16 Dec 2009 14:02:26 +0100
Message-ID: <4B28DA62.40909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, mcarlson@broadcom.com,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756512AbZLPNAh@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If not signed read errors are ignored.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Found using coccinelle: http://coccinelle.lip6.fr/

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index f63c96a..c13cf64 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -326,7 +326,8 @@ error:
 
 static void bcm54xx_adjust_rxrefclk(struct phy_device *phydev)
 {
-	u32 val, orig;
+	u32 orig;
+	int val;
 	bool clk125en = true;
 
 	/* Abort if we are using an untested phy. */
