From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 11/16] Host AP: Fix PRISM2_IO_DEBUG
Date: Sat, 13 Nov 2004 21:20:04 -0800
Message-ID: <20041114052004.GC14810@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu> <20041108071710.GL1076@jm.kir.nu> <419071F0.6030602@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <419071F0.6030602@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>From Mark Glines <mark@glines.org>:

I just noticed PRISM2_IO_DEBUG doesn't work.  This patch gets it
working again.  I checked the development CVS snapshot, looks like
its still broken there.

jkm: in addition, fix the other PRISM2_IO_DEBUG function

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
--- a/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-13 20:56:09 -08:00
+++ b/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-13 20:56:09 -08:00
@@ -1004,7 +1004,8 @@
 static inline void prism2_io_debug_add(struct net_device *dev, int cmd,
 				       int reg, int value)
 {
-	local_info_t *local = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
+	local_info_t *local = iface->local;
 
 	if (!local->io_debug_enabled)
 		return;
@@ -1021,7 +1022,8 @@
 
 static inline void prism2_io_debug_error(struct net_device *dev, int err)
 {
-	local_info_t *local = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
+	local_info_t *local = iface->local;
 	unsigned long flags;
 
 	if (!local->io_debug_enabled)


-- 
Jouni Malinen                                            PGP id EFC895FA
