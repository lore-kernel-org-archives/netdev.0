From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/4) add random_ether_addr to ether_device.h
Date: Fri, 9 Apr 2004 11:45:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409114547.7ef37fc0@dell_ss3.pdx.osdl.net>
References: <20040408110834.2fd1bd25@dell_ss3.pdx.osdl.net>
	<20040408145403.34382c96.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-usb-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040408145403.34382c96.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Since generating a random ethernet address needs to be done
in several drivers, add a random_ether_addr function to etherdevice.h

diff -Nru a/include/linux/etherdevice.h b/include/linux/etherdevice.h
--- a/include/linux/etherdevice.h	Fri Apr  9 11:33:59 2004
+++ b/include/linux/etherdevice.h	Fri Apr  9 11:33:59 2004
@@ -25,6 +25,7 @@
 #define _LINUX_ETHERDEVICE_H
 
 #include <linux/if_ether.h>
+#include <linux/random.h>
 
 #ifdef __KERNEL__
 extern int		eth_header(struct sk_buff *skb, struct net_device *dev,
@@ -64,6 +65,19 @@
 	return !(addr[0]&1) && memcmp( addr, zaddr, 6);
 }
 
+/**
+ * random_ether_addr - Generate software assigned random Ethernet address
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Generate a random Ethernet address (MAC) that is not multicast
+ * and has the local assigned bit set.
+ */
+static inline void random_ether_addr(u8 *addr)
+{
+	get_random_bytes (addr, ETH_ALEN);
+	addr [0] &= 0xfe;	/* clear multicast bit */
+	addr [0] |= 0x02;	/* set local assignment bit (IEEE802) */
+}
 #endif
 
 #endif	/* _LINUX_ETHERDEVICE_H */
