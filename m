From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/5) irda_device_setup should match ether_setup
Date: Fri, 15 Aug 2003 15:52:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815155254.5580d60a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

irda_device_setup signature should match ether_setup so it can
be used with alloc_netdev.  No caller was checking the return
value anyway.

diff -Nru a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
--- a/include/net/irda/irda_device.h	Fri Aug 15 13:07:28 2003
+++ b/include/net/irda/irda_device.h	Fri Aug 15 13:07:28 2003
@@ -222,7 +222,7 @@
 int  irda_device_set_raw_mode(struct net_device* self, int status);
 int  irda_device_set_dtr_rts(struct net_device *dev, int dtr, int rts);
 int  irda_device_change_speed(struct net_device *dev, __u32 speed);
-int  irda_device_setup(struct net_device *dev);
+void irda_device_setup(struct net_device *dev);
 
 /* Dongle interface */
 void irda_device_unregister_dongle(struct dongle_reg *dongle);
diff -Nru a/net/irda/irda_device.c b/net/irda/irda_device.c
--- a/net/irda/irda_device.c	Fri Aug 15 13:07:28 2003
+++ b/net/irda/irda_device.c	Fri Aug 15 13:07:28 2003
@@ -383,10 +383,8 @@
  *    This function should be used by low level device drivers in a similar way
  *    as ether_setup() is used by normal network device drivers
  */
-int irda_device_setup(struct net_device *dev)
+void irda_device_setup(struct net_device *dev)
 {
-	ASSERT(dev != NULL, return -1;);
-
         dev->hard_header_len = 0;
         dev->addr_len        = 0;
 
@@ -399,7 +397,6 @@
 
 	dev->mtu = 2048;
 	dev->flags = IFF_NOARP;
-	return 0;
 }
 
 /*
