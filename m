From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 9/12] Host AP: Fix card enabling after firmware download
Date: Sun, 7 Nov 2004 23:15:36 -0800
Message-ID: <20041108071536.GJ1076@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix card enabling after firmware download in case any of the
netdevs were up when the download was started.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
--- a/drivers/net/wireless/hostap/hostap_hw.c	2004-11-07 22:39:00 -08:00
+++ b/drivers/net/wireless/hostap/hostap_hw.c	2004-11-07 22:39:00 -08:00
@@ -1483,7 +1483,10 @@
 	if (prism2_hw_init2(dev, initial))
 		return 1;
 
-	if (!local->pri_only && !initial) {
+	/* Enable firmware if secondary image is loaded and at least one of the
+	 * netdevices is up. */
+	if (!local->pri_only &&
+	    (initial == 0 || (initial == 2 && local->num_dev_open > 0))) {
 		if (!local->dev_enabled)
 			prism2_callback(local, PRISM2_CALLBACK_ENABLE);
 		local->dev_enabled = 1;


-- 
Jouni Malinen                                            PGP id EFC895FA
