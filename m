From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.4-rc2] netdevice.h add netif_msg_init helper
Date: Thu, 4 Mar 2004 03:05:37 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403041105.i24B5bZ01272@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds a helper function to initialize the debug bit mask
for use with netif_msg_*.  When the debug_value is out of range
it returns the default_msg_enable_bits.

--- linux-2.6.4-rc2/include/linux/orig.netdevice.h	Thu Mar  4 09:59:08 2004
+++ linux-2.6.4-rc2/include/linux/netdevice.h	Thu Mar  4 10:56:19 2004
@@ -774,6 +774,17 @@
 #define netif_msg_hw(p)		((p)->msg_enable & NETIF_MSG_HW)
 #define netif_msg_wol(p)	((p)->msg_enable & NETIF_MSG_WOL)
 
+static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
+{
+	/* use default */
+	if (debug_value < 0 || debug_value > (sizeof(u32) * 8))
+		return default_msg_enable_bits;
+	if (debug_value == 0)	/* no output */
+		return 0;
+	/* set low N bits */
+	return(((debug_value == (sizeof(u32)*8)) ? 0 : (1 << debug_value)) - 1);
+}
+
 /* Schedule rx intr now? */
 
 static inline int netif_rx_schedule_prep(struct net_device *dev)

-- 
Don Fry
brazilnut@us.ibm.com
