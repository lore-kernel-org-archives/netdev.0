From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: Enable fwpostfix in nondebug bcm43xx
Date: Sun, 28 Jan 2007 14:32:52 -0600
Message-ID: <45bd0874.hBM9rX68Vq5hLGwU%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

The in-kernel bcm43xx driver only works with V3 firmware, whereas the
experimental version that incorporates the d80211 stack requires V4
firmware. In bcm43xx-d80211, the fwpostfix module parameter is used
to differentiate between the versions. In bcm43xx-softmac, this
module parameter is only enabled when debugging is on. This patch
makes the module parameter available unconditionaly, and should
ease the future transition from softmac to d80211.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
--

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -96,13 +96,9 @@ static int modparam_noleds;
 module_param_named(noleds, modparam_noleds, int, 0444);
 MODULE_PARM_DESC(noleds, "Turn off all LED activity");
 
-#ifdef CONFIG_BCM43XX_DEBUG
 static char modparam_fwpostfix[64];
 module_param_string(fwpostfix, modparam_fwpostfix, 64, 0444);
-MODULE_PARM_DESC(fwpostfix, "Postfix for .fw files. Useful for debugging.");
-#else
-# define modparam_fwpostfix  ""
-#endif /* CONFIG_BCM43XX_DEBUG*/
+MODULE_PARM_DESC(fwpostfix, "Postfix for .fw files. Useful for using multiple firmware image versions.");
 
 
 /* If you want to debug with just a single device, enable this,

---
