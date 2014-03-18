From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] micrel: fix masking off LED bits
Date: Wed, 19 Mar 2014 02:58:16 +0300
Message-ID: <201403190258.16812.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, ben.dooks@codethink.co.uk
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 20d8435a1cff (phy: micrel: add of configuration for LED mode) made the
obvious mistake when masking off  the LED mode bits: forgot to do a logical NOT
to the mask with which it ANDs the register value, so that unrelated bits are
cleared instead.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against DaveM's 'net-next.git' repo.

 drivers/net/phy/micrel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/phy/micrel.c
===================================================================
--- net-next.orig/drivers/net/phy/micrel.c
+++ net-next/drivers/net/phy/micrel.c
@@ -167,7 +167,7 @@ static int kszphy_setup_led(struct phy_d
 	if (temp < 0)
 		return temp;
 
-	temp &= 3 << shift;
+	temp &= ~(3 << shift);
 	temp |= val << shift;
 	rc = phy_write(phydev, reg, temp);
 
