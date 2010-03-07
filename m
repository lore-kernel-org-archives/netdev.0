From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/3] cpmac: fix the receiving of 802.1q frames
Date: Sun, 7 Mar 2010 11:55:26 +0100
Message-ID: <201003071155.27947.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:63171 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab0CGKza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 05:55:30 -0500
Received: by mail-bw0-f222.google.com with SMTP id 22so2144929bwz.28
        for <netdev@vger.kernel.org>; Sun, 07 Mar 2010 02:55:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Despite what the comment above CPMAC_SKB_SIZE says, the hardware also
needs to account for the FCS length in a received frame. This patch fix
the receiving of 802.1q frames which have 4 more bytes. While at it
unhardcode the definition and use the one from if_vlan.h.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index b85c81f..722a196 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -28,6 +28,7 @@
 #include <linux/delay.h>
 
 #include <linux/netdevice.h>
+#include <linux/if_vlan.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/skbuff.h>
@@ -56,8 +57,8 @@ MODULE_PARM_DESC(debug_level, "Number of NETIF_MSG bits to enable");
 MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
 
 #define CPMAC_VERSION "0.5.1"
-/* frame size + 802.1q tag */
-#define CPMAC_SKB_SIZE		(ETH_FRAME_LEN + 4)
+/* frame size + 802.1q tag + FCS size */
+#define CPMAC_SKB_SIZE		(ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
 #define CPMAC_QUEUES	8
 
 /* Ethernet registers */
