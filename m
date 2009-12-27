From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] usbnet: test off by one
Date: Sun, 27 Dec 2009 22:22:08 +0100
Message-ID: <4B37D000.6070009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Petko Manolov <petkan@users.sourceforge.net>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751418AbZL0VTT@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With `while (i++ < MII_TIMEOUT)' i reaches MII_TIMEOUT + 1 after the loop
This is probably unlikely a problem in practice.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/usb/rtl8150.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index f14d225..fd19db0 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -270,7 +270,7 @@ static int read_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 * reg)
 		get_registers(dev, PHYCNT, 1, data);
 	} while ((data[0] & PHY_GO) && (i++ < MII_TIMEOUT));
 
-	if (i < MII_TIMEOUT) {
+	if (i <= MII_TIMEOUT) {
 		get_registers(dev, PHYDAT, 2, data);
 		*reg = data[0] | (data[1] << 8);
 		return 0;
@@ -295,7 +295,7 @@ static int write_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 reg)
 		get_registers(dev, PHYCNT, 1, data);
 	} while ((data[0] & PHY_GO) && (i++ < MII_TIMEOUT));
 
-	if (i < MII_TIMEOUT)
+	if (i <= MII_TIMEOUT)
 		return 0;
 	else
 		return 1;
