From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.5] (1/9) bridge - include file cleanup
Date: Tue, 13 Apr 2004 15:16:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanup some of the include file's in the bridge code.
* if_bridge.h defines net_bridge, but not needed as part of the API.
* get rid of places that include if_bridge.h and uaccess.h but don't
  actually do API work.


diff -Nru a/include/linux/if_bridge.h b/include/linux/if_bridge.h
--- a/include/linux/if_bridge.h	Tue Apr 13 14:44:58 2004
+++ b/include/linux/if_bridge.h	Tue Apr 13 14:44:58 2004
@@ -99,9 +99,6 @@
 
 #include <linux/netdevice.h>
 
-struct net_bridge;
-struct net_bridge_port;
-
 extern void brioctl_set(int (*ioctl_hook)(unsigned long));
 extern int (*br_handle_frame_hook)(struct sk_buff *skb);
 extern int (*br_should_route_hook)(struct sk_buff **pskb);
diff -Nru a/net/bridge/br.c b/net/bridge/br.c
--- a/net/bridge/br.c	Tue Apr 13 14:44:58 2004
+++ b/net/bridge/br.c	Tue Apr 13 14:44:58 2004
@@ -20,8 +20,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
-#include <linux/if_bridge.h>
-#include <asm/uaccess.h>
+
 #include "br_private.h"
 
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
diff -Nru a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c	Tue Apr 13 14:44:58 2004
+++ b/net/bridge/br_device.c	Tue Apr 13 14:44:58 2004
@@ -15,7 +15,6 @@
 
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-#include <linux/if_bridge.h>
 #include <linux/module.h>
 #include <asm/uaccess.h>
 #include "br_private.h"
diff -Nru a/net/bridge/br_forward.c b/net/bridge/br_forward.c
--- a/net/bridge/br_forward.c	Tue Apr 13 14:44:58 2004
+++ b/net/bridge/br_forward.c	Tue Apr 13 14:44:58 2004
@@ -15,9 +15,7 @@
 
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-#include <linux/inetdevice.h>
 #include <linux/skbuff.h>
-#include <linux/if_bridge.h>
 #include <linux/netfilter_bridge.h>
 #include "br_private.h"
 
diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	Tue Apr 13 14:44:58 2004
+++ b/net/bridge/br_if.c	Tue Apr 13 14:44:58 2004
@@ -15,13 +15,11 @@
 
 #include <linux/kernel.h>
 #include <linux/if_arp.h>
-#include <linux/if_bridge.h>
-#include <linux/inetdevice.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/rtnetlink.h>
 #include <net/sock.h>
-#include <asm/uaccess.h>
+
 #include "br_private.h"
 
 /* Limited to 256 ports because of STP protocol pdu */
diff -Nru a/net/bridge/br_input.c b/net/bridge/br_input.c
--- a/net/bridge/br_input.c	Tue Apr 13 14:44:58 2004
+++ b/net/bridge/br_input.c	Tue Apr 13 14:44:58 2004
@@ -16,7 +16,6 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/if_bridge.h>
 #include <linux/netfilter_bridge.h>
 #include "br_private.h"
 
diff -Nru a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
--- a/net/bridge/br_ioctl.c	Tue Apr 13 14:44:58 2004
+++ b/net/bridge/br_ioctl.c	Tue Apr 13 14:44:58 2004
@@ -15,7 +15,7 @@
 
 #include <linux/kernel.h>
 #include <linux/if_bridge.h>
-#include <linux/inetdevice.h>
+#include <linux/netdevice.h>
 #include <asm/uaccess.h>
 #include "br_private.h"
 
diff -Nru a/net/bridge/br_notify.c b/net/bridge/br_notify.c
--- a/net/bridge/br_notify.c	Tue Apr 13 14:44:58 2004
+++ b/net/bridge/br_notify.c	Tue Apr 13 14:44:58 2004
@@ -14,7 +14,7 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/if_bridge.h>
+
 #include "br_private.h"
 
 static int br_device_event(struct notifier_block *unused, unsigned long event, void *ptr);
diff -Nru a/net/bridge/br_stp.c b/net/bridge/br_stp.c
--- a/net/bridge/br_stp.c	Tue Apr 13 14:44:58 2004
+++ b/net/bridge/br_stp.c	Tue Apr 13 14:44:58 2004
@@ -13,9 +13,8 @@
  *	2 of the License, or (at your option) any later version.
  */
 #include <linux/kernel.h>
-#include <linux/if_bridge.h>
 #include <linux/smp_lock.h>
-#include <asm/uaccess.h>
+
 #include "br_private.h"
 #include "br_private_stp.h"
 
diff -Nru a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
--- a/net/bridge/br_stp_bpdu.c	Tue Apr 13 14:44:58 2004
+++ b/net/bridge/br_stp_bpdu.c	Tue Apr 13 14:44:58 2004
@@ -14,9 +14,8 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/if_ether.h>
-#include <linux/if_bridge.h>
 #include <linux/netfilter_bridge.h>
+
 #include "br_private.h"
 #include "br_private_stp.h"
 
diff -Nru a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
--- a/net/bridge/br_stp_if.c	Tue Apr 13 14:44:58 2004
+++ b/net/bridge/br_stp_if.c	Tue Apr 13 14:44:58 2004
@@ -14,9 +14,8 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/if_bridge.h>
 #include <linux/smp_lock.h>
-#include <asm/uaccess.h>
+
 #include "br_private.h"
 #include "br_private_stp.h"
 
diff -Nru a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
--- a/net/bridge/br_stp_timer.c	Tue Apr 13 14:44:58 2004
+++ b/net/bridge/br_stp_timer.c	Tue Apr 13 14:44:58 2004
@@ -14,9 +14,8 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/if_bridge.h>
 #include <linux/smp_lock.h>
-#include <asm/uaccess.h>
+
 #include "br_private.h"
 #include "br_private_stp.h"
 
