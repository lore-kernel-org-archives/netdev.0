From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.5] (5/9) bridge - multicast address as const
Date: Tue, 13 Apr 2004 15:26:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040413152620.2a0f0bd1@dell_ss3.pdx.osdl.net>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Trivial change.  For places where bridge multicast address is defined,
or compared use constant.

diff -Nru a/net/bridge/br_input.c b/net/bridge/br_input.c
--- a/net/bridge/br_input.c	Mon Apr 12 16:10:36 2004
+++ b/net/bridge/br_input.c	Mon Apr 12 16:10:36 2004
@@ -19,7 +19,7 @@
 #include <linux/netfilter_bridge.h>
 #include "br_private.h"
 
-unsigned char bridge_ula[6] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
+const unsigned char bridge_ula[6] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
 
 static int br_pass_frame_up_finish(struct sk_buff *skb)
 {
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	Mon Apr 12 16:10:36 2004
+++ b/net/bridge/br_private.h	Mon Apr 12 16:10:36 2004
@@ -111,7 +111,7 @@
 };
 
 extern struct notifier_block br_device_notifier;
-extern unsigned char bridge_ula[6];
+extern const unsigned char bridge_ula[6];
 
 /* called under bridge lock */
 static inline int br_is_root_bridge(const struct net_bridge *br)
diff -Nru a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
--- a/net/bridge/br_stp_if.c	Mon Apr 12 16:10:36 2004
+++ b/net/bridge/br_stp_if.c	Mon Apr 12 16:10:36 2004
@@ -110,7 +110,8 @@
 }
 
 /* called under bridge lock */
-static void br_stp_change_bridge_id(struct net_bridge *br, unsigned char *addr)
+static void br_stp_change_bridge_id(struct net_bridge *br, 
+				    const unsigned char *addr)
 {
 	unsigned char oldaddr[6];
 	struct net_bridge_port *p;
@@ -137,15 +138,13 @@
 		br_become_root_bridge(br);
 }
 
-static unsigned char br_mac_zero[6];
+static const unsigned char br_mac_zero[6];
 
 /* called under bridge lock */
 void br_stp_recalculate_bridge_id(struct net_bridge *br)
 {
-	unsigned char *addr;
+	const unsigned char *addr = br_mac_zero;
 	struct net_bridge_port *p;
-
-	addr = br_mac_zero;
 
 	list_for_each_entry(p, &br->port_list, list) {
 		if (addr == br_mac_zero ||
