From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/16) add alloc_irdadev
Date: Tue, 30 Sep 2003 14:59:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930145943.2c45442f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For 2.6.0-test6 add alloc_irdadev in same manner as alloc_etherdev.

diff -Nru a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
--- a/include/net/irda/irda_device.h	Tue Sep 30 11:56:19 2003
+++ b/include/net/irda/irda_device.h	Tue Sep 30 11:56:19 2003
@@ -223,6 +223,7 @@
 int  irda_device_set_dtr_rts(struct net_device *dev, int dtr, int rts);
 int  irda_device_change_speed(struct net_device *dev, __u32 speed);
 void irda_device_setup(struct net_device *dev);
+struct net_device *alloc_irdadev(int sizeof_priv);
 
 /* Dongle interface */
 void irda_device_unregister_dongle(struct dongle_reg *dongle);
diff -Nru a/net/irda/irda_device.c b/net/irda/irda_device.c
--- a/net/irda/irda_device.c	Tue Sep 30 11:56:19 2003
+++ b/net/irda/irda_device.c	Tue Sep 30 11:56:19 2003
@@ -388,6 +388,17 @@
 }
 
 /*
+ * Funciton  alloc_irdadev 
+ * 	Allocates and sets up an IRDA device in a manner similar to
+ * 	alloc_etherdev.
+ */
+struct net_device *alloc_irdadev(int sizeof_priv)
+{
+	return alloc_netdev(sizeof_priv, "irda%d", irda_device_setup);
+}
+
+
+/*
  * Function irda_device_txqueue_empty (dev)
  *
  *    Check if there is still some frames in the transmit queue for this
diff -Nru a/net/irda/irsyms.c b/net/irda/irsyms.c
--- a/net/irda/irsyms.c	Tue Sep 30 11:56:19 2003
+++ b/net/irda/irsyms.c	Tue Sep 30 11:56:19 2003
@@ -150,6 +150,7 @@
 EXPORT_SYMBOL(irda_init_max_qos_capabilies);
 EXPORT_SYMBOL(irda_qos_bits_to_value);
 EXPORT_SYMBOL(irda_device_setup);
+EXPORT_SYMBOL(alloc_irdadev);
 EXPORT_SYMBOL(irda_device_set_media_busy);
 EXPORT_SYMBOL(irda_device_txqueue_empty);
 
