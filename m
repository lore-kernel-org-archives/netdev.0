From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: Fix incorrect definition of PHY revision
Date: Tue, 06 Feb 2007 21:31:45 -0600
Message-ID: <45c94821.qjljSnUzfws7mU7T%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

There is a typographical error in the spefications that interchange the PHY version
and revision. Fixing this error makes all BCM43xx varieties work at full CCCK rates.

Signed-off-by: Larry Finger<Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

This patch should be put into wireless-2.6 and into 'upstream' as soon as possible.
I will be sending it to stable for inclusion in 2.6.20.1, and whatever other kernels
are still being maintained by -stable.

Larry
---
 
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3704,9 +3704,9 @@ static int bcm43xx_read_phyinfo(struct b
 
 	value = bcm43xx_read16(bcm, BCM43xx_MMIO_PHY_VER);
 
-	phy_version = (value & 0xF000) >> 12;
+	phy_rev = (value & 0xF000) >> 12;
 	phy_type = (value & 0x0F00) >> 8;
-	phy_rev = (value & 0x000F);
+	phy_version = (value & 0x000F);
 
 	dprintk(KERN_INFO PFX "Detected PHY: Version: %x, Type %x, Revision %x\n",
 		phy_version, phy_type, phy_rev);

===
