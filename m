From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: [RFC PATCH 1/1] ethtool: adding support for multiple slave port configuration
Date: Fri, 25 Jul 2014 17:58:25 +0530
Message-ID: <1406291305-22286-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	<linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some Ethernet Swtich controllers like CPSW in AM335x, TI814x, DRA7x and
AM43xx SoCs, Network Coprocessor in AM5K2E0x, Realtek Switch controllers
etc has to capability of conneting multiple networks using L2 switching
and has multiple phys. With the existing code, ethtool can communicate
only to one phy.

To enable user to communicate multiple phy connected to single Ethernet
Switch controller, intoducing a optional new parameter in Ethtool interface
to pass which slave to set/get the phy configuration.

Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
---
 include/uapi/linux/ethtool.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 96ade34..3011427 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -60,6 +60,9 @@
  *	and other link features that the link partner advertised
  *	through autonegotiation; 0 if unknown or not applicable.
  *	Read-only.
+ * @slave_port: Specify which slave port to be used to set/get
+ *	parmeters, for example which slave port phy to be used for
+ *	set/get phy capabilities
  *
  * The link speed in Mbps is split between @speed and @speed_hi.  Use
  * the ethtool_cmd_speed() and ethtool_cmd_speed_set() functions to
@@ -107,7 +110,8 @@ struct ethtool_cmd {
 	__u8	eth_tp_mdix;
 	__u8	eth_tp_mdix_ctrl;
 	__u32	lp_advertising;
-	__u32	reserved[2];
+	__u32	slave_port;
+	__u32	reserved;
 };
 
 static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
-- 
2.0.2.673.g9ab0882
