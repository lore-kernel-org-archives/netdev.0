From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70] remove if_port_text
Date: Thu, 29 May 2003 14:28:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529142820.5f657d77.shemminger@osdl.org>
References: <20030529104138.751a1f54.shemminger@osdl.org>
	<20030529.140828.78714529.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: scott.feldman@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030529.140828.78714529.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eliminate necrophilic code, net-sysfs shouldn't support deprecated if_port.
Since nowhere else is using if_port_text, eliminate it.

diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	Thu May 29 14:24:18 2003
+++ b/include/linux/netdevice.h	Thu May 29 14:24:18 2003
@@ -147,8 +147,6 @@
 
 #ifdef __KERNEL__
 
-extern const char *if_port_text[];
-
 #include <linux/cache.h>
 #include <linux/skbuff.h>
 
diff -Nru a/net/core/net-sysfs.c b/net/core/net-sysfs.c
--- a/net/core/net-sysfs.c	Thu May 29 14:24:18 2003
+++ b/net/core/net-sysfs.c	Thu May 29 14:24:18 2003
@@ -16,16 +16,6 @@
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
 
-const char *if_port_text[] = {
-   [IF_PORT_UNKNOWN] = "unknown",
-   [IF_PORT_10BASE2] = "BNC",
-   [IF_PORT_10BASET] = "10baseT",
-   [IF_PORT_AUI]     = "AUI",
-   [IF_PORT_100BASET] = "100baseT",
-   [IF_PORT_100BASETX] = "100baseTX",
-   [IF_PORT_100BASEFX] = "100baseFX"
-};
-
 #define to_net_dev(class) container_of((class), struct net_device, class_dev)
 
 /* generate a show function for  simple field */
@@ -66,20 +56,6 @@
 NETDEVICE_ATTR(features, "%#x\n");
 NETDEVICE_ATTR(type, "%d\n");
 
-/* TODO: only a few devices set this now should fix others. */
-static ssize_t show_port(struct class_device *dev, char *buf)
-{
-	unsigned char port = to_net_dev(dev)->if_port;
-	char *cp = buf;
-
-	cp += sprintf(cp, "%d", port);
-	if (port < ARRAY_SIZE(if_port_text))
-		cp += sprintf(cp, " (%s)", if_port_text[port]);
-	*cp++ ='\n';
-	return cp - buf;
-}
-static CLASS_DEVICE_ATTR(if_port, S_IRUGO, show_port, NULL);
-
 static ssize_t format_addr(char *buf, const unsigned char *addr, int len)
 {
 	int i;
@@ -175,7 +151,6 @@
 	&class_device_attr_features,
 	&class_device_attr_mtu,
 	&class_device_attr_flags,
-	&class_device_attr_if_port,
 	&class_device_attr_type,
 	&class_device_attr_address,
 	&class_device_attr_broadcast,
diff -Nru a/net/netsyms.c b/net/netsyms.c
--- a/net/netsyms.c	Thu May 29 14:24:18 2003
+++ b/net/netsyms.c	Thu May 29 14:24:18 2003
@@ -609,8 +609,6 @@
 EXPORT_SYMBOL(dev_mc_upload);
 EXPORT_SYMBOL(__kill_fasync);
 
-EXPORT_SYMBOL(if_port_text);
-
 #ifdef CONFIG_HIPPI
 EXPORT_SYMBOL(hippi_type_trans);
 #endif
