From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.4.26-pre2] netdevice.h: add netif_msg_init helper
Date: Mon, 8 Mar 2004 11:10:46 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403081910.i28JAli10587@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply the following patch to 2.4.26-pre2

This patch adds a helper function to initialize the debug bit mask
for use with netif_msg_*.  When the debug_value is out of range
it returns the default_msg_enable_bits.  Tested IA32.

--- orig.linux-2.4.26-pre2/include/linux/netdevice.h	Wed Feb 18 05:36:32 2004
+++ linux-2.4.26-pre2/include/linux/netdevice.h	Mon Mar  8 10:10:23 2004
@@ -732,6 +732,17 @@
 #define netif_msg_hw(p)		((p)->msg_enable & NETIF_MSG_HW)
 #define netif_msg_wol(p)	((p)->msg_enable & NETIF_MSG_WOL)
 
+static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
+{
+	/* use default */
+	if (debug_value < 0 || debug_value >= (sizeof(u32) * 8))
+		return default_msg_enable_bits;
+	if (debug_value == 0)	/* no output */
+		return 0;
+	/* set low N bits */
+	return (1 << debug_value) - 1;
+}
+
 /* Schedule rx intr now? */
 
 static inline int netif_rx_schedule_prep(struct net_device *dev)

-- 
Don Fry
brazilnut@us.ibm.com
