From: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v6 2/6] 6lowpan: Set MAC address length according to LOWPAN_LLTYPE
Date: Thu,  2 Mar 2017 15:23:31 +0200
Message-ID: <20170302132335.21192-3-luiz.dentz@gmail.com>
References: <20170302132335.21192-1-luiz.dentz@gmail.com>
Cc: patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
        jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170302132335.21192-1-luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Patrik Flykt <patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

Set MAC address length according to the 6LoWPAN link layer in use.
Bluetooth Low Energy uses 48 bit addressing while IEEE802.15.4 uses
64 bits.

Signed-off-by: Patrik Flykt <patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
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
