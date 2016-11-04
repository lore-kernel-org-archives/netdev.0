From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool 1/2] ethtool-copy.h:sync with net
Date: Fri, 4 Nov 2016 11:36:44 +0100
Message-ID: <1478255805-25823-2-git-send-email-allan.nielsen@microsemi.com>
References: <1478255805-25823-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        <cphealy@gmail.com>, <robh@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0066.outbound.protection.outlook.com ([104.47.40.66]:1150
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1761108AbcKDKhC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 06:37:02 -0400
In-Reply-To: <1478255805-25823-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This covers kernel changes upto:

commit 67168af82f30bacbd734a4472670cba6b3d6fd36
Author: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Date:   Wed Nov 2 11:35:12 2016 +0530

    ethtool: (uapi) Add ETHTOOL_PHY_DOWNSHIFT to PHY tunables

    For operation in cabling environments that are incompatible with 1000BAST-T, PHY
    device may provide an automatic link speed downshift operation. When enabled,
    the device automatically changes its 1000BAST-T auto-negotiation to the next
    slower speed after a configured number of failed attempts at 1000BAST-T.  This
    feature is useful in setting up in networks using older cable installations that
    include only pairs A and B, and not pairs C and D.

    Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
    Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>

Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 ethtool-copy.h | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 70748f5..040c5b5 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -10,14 +10,16 @@
  * Portions Copyright (C) Sun Microsystems 2008
  */
 
-#ifndef _LINUX_ETHTOOL_H
-#define _LINUX_ETHTOOL_H
+#ifndef _UAPI_LINUX_ETHTOOL_H
+#define _UAPI_LINUX_ETHTOOL_H
 
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
+#ifndef __KERNEL__
 #include <limits.h> /* for INT_MAX */
+#endif
 
 /* All structures exposed to userland should be defined such that they
  * have the same layout for 32-bit and 64-bit userland.
@@ -114,15 +116,14 @@ struct ethtool_cmd {
 	__u32	reserved[2];
 };
 
-static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
+static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 					 __u32 speed)
 {
-
-	ep->speed = (__u16)speed;
+	ep->speed = (__u16)(speed & 0xFFFF);
 	ep->speed_hi = (__u16)(speed >> 16);
 }
 
-static __inline__ __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
+static inline __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
 {
 	return (ep->speed_hi << 16) | ep->speed;
 }
@@ -247,6 +248,14 @@ struct ethtool_tunable {
 	void	*data[0];
 };
 
+#define DOWNSHIFT_DEV_DEFAULT_COUNT	0xff
+#define DOWNSHIFT_DEV_DISABLE		0
+
+enum phy_tunable_id {
+	ETHTOOL_PHY_ID_UNSPEC,
+	ETHTOOL_PHY_DOWNSHIFT,
+};
+
 /**
  * struct ethtool_regs - hardware register dump
  * @cmd: Command number = %ETHTOOL_GREGS
@@ -878,12 +887,12 @@ struct ethtool_rx_flow_spec {
 #define ETHTOOL_RX_FLOW_SPEC_RING	0x00000000FFFFFFFFLL
 #define ETHTOOL_RX_FLOW_SPEC_RING_VF	0x000000FF00000000LL
 #define ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF 32
-static __inline__ __u64 ethtool_get_flow_spec_ring(__u64 ring_cookie)
+static inline __u64 ethtool_get_flow_spec_ring(__u64 ring_cookie)
 {
 	return ETHTOOL_RX_FLOW_SPEC_RING & ring_cookie;
 };
 
-static __inline__ __u64 ethtool_get_flow_spec_ring_vf(__u64 ring_cookie)
+static inline __u64 ethtool_get_flow_spec_ring_vf(__u64 ring_cookie)
 {
 	return (ETHTOOL_RX_FLOW_SPEC_RING_VF & ring_cookie) >>
 				ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF;
@@ -1312,7 +1321,8 @@ struct ethtool_per_queue_op {
 
 #define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings */
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
-
+#define ETHTOOL_PHY_GTUNABLE	0x0000004e /* Get PHY tunable configuration */
+#define ETHTOOL_PHY_STUNABLE	0x0000004f /* Set PHY tunable configuration */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1483,7 +1493,7 @@ enum ethtool_link_mode_bit_indices {
 
 #define SPEED_UNKNOWN		-1
 
-static __inline__ int ethtool_validate_speed(__u32 speed)
+static inline int ethtool_validate_speed(__u32 speed)
 {
 	return speed <= INT_MAX || speed == SPEED_UNKNOWN;
 }
@@ -1493,7 +1503,7 @@ static __inline__ int ethtool_validate_speed(__u32 speed)
 #define DUPLEX_FULL		0x01
 #define DUPLEX_UNKNOWN		0xff
 
-static __inline__ int ethtool_validate_duplex(__u8 duplex)
+static inline int ethtool_validate_duplex(__u8 duplex)
 {
 	switch (duplex) {
 	case DUPLEX_HALF:
@@ -1743,4 +1753,4 @@ struct ethtool_link_settings {
 	 * __u32 map_lp_advertising[link_mode_masks_nwords];
 	 */
 };
-#endif /* _LINUX_ETHTOOL_H */
+#endif /* _UAPI_LINUX_ETHTOOL_H */
-- 
2.7.3
