From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: [PATCH v5 2/6] 6lowpan: Set MAC address length according to LOWPAN_LLTYPE
Date: Fri, 24 Feb 2017 14:14:36 +0200
Message-ID: <20170224121440.32269-3-luiz.dentz@gmail.com>
References: <20170224121440.32269-1-luiz.dentz@gmail.com>
Cc: patrik.flykt@linux.intel.com, jukka.rissanen@linux.intel.com,
        stefan@osg.samsung.com, aar@pengutronix.de,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:32864 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751219AbdBXMPB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 07:15:01 -0500
In-Reply-To: <20170224121440.32269-1-luiz.dentz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrik Flykt <patrik.flykt@linux.intel.com>

Set MAC address length according to the 6LoWPAN link layer in use.
Bluetooth Low Energy uses 48 bit addressing while IEEE802.15.4 uses
64 bits.

Signed-off-by: Patrik Flykt <patrik.flykt@linux.intel.com>
Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
---
 net/6lowpan/core.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
index 5945f7e..5f9909a 100644
--- a/net/6lowpan/core.c
+++ b/net/6lowpan/core.c
@@ -23,7 +23,16 @@ int lowpan_register_netdevice(struct net_device *dev,
 {
 	int i, ret;
 
-	dev->addr_len = EUI64_ADDR_LEN;
+	switch (lltype) {
+	case LOWPAN_LLTYPE_IEEE802154:
+		dev->addr_len = EUI64_ADDR_LEN;
+		break;
+
+	case LOWPAN_LLTYPE_BTLE:
+		dev->addr_len = ETH_ALEN;
+		break;
+	}
+
 	dev->type = ARPHRD_6LOWPAN;
 	dev->mtu = IPV6_MIN_MTU;
 	dev->priv_flags |= IFF_NO_QUEUE;
-- 
2.9.3
