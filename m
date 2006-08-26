From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] ssb: Add support for new ChipCommon
Date: Sat, 26 Aug 2006 12:33:32 +0200
Message-ID: <200608261233.32336.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Content-Disposition: inline
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

Hi John,

Please apply this to wireless-dev.

--

This adds support for the new 0x900 ChipCommon core.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: wireless-dev/drivers/misc/ssb.c
===================================================================
--- wireless-dev.orig/drivers/misc/ssb.c	2006-08-24 22:33:44.000000000 +0200
+++ wireless-dev/drivers/misc/ssb.c	2006-08-26 12:28:31.000000000 +0200
@@ -648,7 +648,7 @@
 
 	ssb->chipcommon_capabilities = 0;
 	ssb->nr_cores = 0;
-	if (cc == SSB_CC_CHIPCOMMON) {
+	if (cc == SSB_CC_CHIPCOMMON || cc == SSB_CC_CHIPCOMMON2) {
 		tmp = ssb_read32(ssb, SSB_CHIPCOMMON_CHIPID);
 
 		ssb->chip_id = (tmp & SSB_CHIPCOMMON_IDMASK);
@@ -656,7 +656,7 @@
 				SSB_CHIPCOMMON_REVSHIFT;
 		ssb->chip_package = (tmp & SSB_CHIPCOMMON_PACKMASK) >>
 				    SSB_CHIPCOMMON_PACKSHIFT;
-		if (rev >= 4) {
+		if (rev >= 4 || cc == SSB_CC_CHIPCOMMON2) {
 			ssb->nr_cores = (tmp & SSB_CHIPCOMMON_NRCORESMASK) >>
 					SSB_CHIPCOMMON_NRCORESSHIFT;
 		}
Index: wireless-dev/include/linux/ssb.h
===================================================================
--- wireless-dev.orig/include/linux/ssb.h	2006-08-24 22:28:03.000000000 +0200
+++ wireless-dev/include/linux/ssb.h	2006-08-26 12:26:11.000000000 +0200
@@ -251,6 +251,7 @@
 #define SSB_CC_MINI_MACPHY	0x823
 #define SSB_CC_ARM_1176		0x824
 #define SSB_CC_ARM_7TDMI	0x825
+#define SSB_CC_CHIPCOMMON2	0x900
 
 
 /* ChipCommon core registers. */


-- 
Greetings Michael.
