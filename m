From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: [PATCH v7 2/6] 6lowpan: Set MAC address length according to LOWPAN_LLTYPE
Date: Sun, 12 Mar 2017 10:19:34 +0200
Message-ID: <20170312081938.11700-3-luiz.dentz@gmail.com>
References: <20170312081938.11700-1-luiz.dentz@gmail.com>
Cc: patrik.flykt@linux.intel.com, aar@pengutronix.de,
        jukka.rissanen@linux.intel.com, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org
To: linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34841 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754702AbdCLITp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 04:19:45 -0400
In-Reply-To: <20170312081938.11700-1-luiz.dentz@gmail.com>
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
