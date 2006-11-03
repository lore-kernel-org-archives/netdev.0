From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: Remove useless core enable/disable messages
Date: Thu, 02 Nov 2006 21:56:52 -0600
Message-ID: <454ABE04.mailGNU11S9GY@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
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

In the softmac version of bcm43xx, the core scan logs whether each core is
enabled or disabled. This information is useless as one of the next steps
is to enable all cores. This patch removes this output from the log.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

These are more janitorial changes for wireless-2.6 and 2.6.20.

Larry


Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2667,14 +2667,10 @@ static int bcm43xx_probe_cores(struct bc
 		bcm->chip_id, bcm->chip_rev);
 	dprintk(KERN_INFO PFX "Number of cores: %d\n", core_count);
 	if (bcm->core_chipcommon.available) {
-		dprintk(KERN_INFO PFX "Core 0: ID 0x%x, rev 0x%x, vendor 0x%x, %s\n",
-			core_id, core_rev, core_vendor,
-			bcm43xx_core_enabled(bcm) ? "enabled" : "disabled");
-	}
-
-	if (bcm->core_chipcommon.available)
+		dprintk(KERN_INFO PFX "Core 0: ID 0x%x, rev 0x%x, vendor 0x%x\n",
+			core_id, core_rev, core_vendor);
 		current_core = 1;
-	else
+	} else
 		current_core = 0;
 	for ( ; current_core < core_count; current_core++) {
 		struct bcm43xx_coreinfo *core;
@@ -2692,9 +2688,8 @@ static int bcm43xx_probe_cores(struct bc
 		core_rev = (sb_id_hi & 0xF);
 		core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
 
-		dprintk(KERN_INFO PFX "Core %d: ID 0x%x, rev 0x%x, vendor 0x%x, %s\n",
-			current_core, core_id, core_rev, core_vendor,
-			bcm43xx_core_enabled(bcm) ? "enabled" : "disabled" );
+		dprintk(KERN_INFO PFX "Core %d: ID 0x%x, rev 0x%x, vendor 0x%x\n",
+			current_core, core_id, core_rev, core_vendor);
 
 		core = NULL;
 		switch (core_id) {
