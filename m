From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 7/14] e1000:  Replace schedule_timeout() with
 msleep()/msleep_interruptible() nacc@us.ibm.com
Date: Thu, 6 Jan 2005 17:21:33 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061531250.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000_ethtool.c net-drivers-2.6/drivers/net/e1000.new/e1000_ethtool.c
--- net-drivers-2.6/drivers/net/e1000/e1000_ethtool.c	2004-12-03 07:24:37.089623336 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_ethtool.c	2004-12-03 07:24:38.346432272 -0800
@@ -1566,9 +1566,7 @@ e1000_phys_id(struct net_device *netdev,
 	e1000_setup_led(&adapter->hw);
 	mod_timer(&adapter->blink_timer, jiffies);
 
-	set_current_state(TASK_INTERRUPTIBLE);
-
-	schedule_timeout(data * HZ);
+	msleep_interruptible(data * 1000);
 	del_timer_sync(&adapter->blink_timer);
 	e1000_led_off(&adapter->hw);
 	clear_bit(E1000_LED_ON, &adapter->led_status);
diff -up net-drivers-2.6/drivers/net/e1000/e1000_osdep.h net-drivers-2.6/drivers/net/e1000.new/e1000_osdep.h
--- net-drivers-2.6/drivers/net/e1000/e1000_osdep.h	2004-12-03 07:24:37.090623184 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_osdep.h	2004-12-03 07:24:38.620390624 -0800
@@ -42,13 +42,8 @@
 #include <linux/sched.h>
 
 #ifndef msec_delay
-#define msec_delay(x)	do { if(in_interrupt()) { \
-				/* Don't mdelay in interrupt context! */ \
-	                	BUG(); \
-			} else { \
-				set_current_state(TASK_UNINTERRUPTIBLE); \
-				schedule_timeout((x * HZ)/1000 + 2); \
-			} } while(0)
+#define msec_delay(x) msleep(x)
+
 /* Some workarounds require millisecond delays and are run during interrupt
  * context.  Most notably, when establishing link, the phy may need tweaking
  * but cannot process phy register reads/writes faster than millisecond
