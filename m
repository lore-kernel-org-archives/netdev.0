From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] bcm43xx: re-add bcm43xx_rng_init() call
Date: Wed, 16 Aug 2006 00:29:07 +0200
Message-ID: <200608160029.07943.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

Please apply this to wireless-2.6.
Please also drop Adrian's patch (If you queued it somewhere):
[RFC: -mm patch] bcm43xx_main.c: remove 3 functions

--

Calls to bcm43xx_rng_init() and bcm43xx_rng_exit() got
lost due to merge trouble. Re-add them.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-08-15 23:27:13.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-08-16 00:14:00.000000000 +0200
@@ -3274,6 +3274,7 @@
 /* This is the opposite of bcm43xx_init_board() */
 static void bcm43xx_free_board(struct bcm43xx_private *bcm)
 {
+	bcm43xx_rng_exit(bcm);
 	bcm43xx_sysfs_unregister(bcm);
 	bcm43xx_periodic_tasks_delete(bcm);
 
@@ -3541,6 +3542,9 @@
 	err = bcm43xx_sysfs_register(bcm);
 	if (err)
 		goto err_wlshutdown;
+	err = bcm43xx_rng_init(bcm);
+	if (err)
+		goto err_sysfs_unreg;
 
 	/*FIXME: This should be handled by softmac instead. */
 	schedule_work(&bcm->softmac->associnfo.work);
@@ -3550,6 +3554,8 @@
 
 	return err;
 
+err_sysfs_unreg:
+	bcm43xx_sysfs_unregister(bcm);
 err_wlshutdown:
 	bcm43xx_shutdown_all_wireless_cores(bcm);
 err_crystal_off:


-- 
Greetings Michael.
