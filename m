From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next] ipv6: addrconf: drop ieee802154 specific things
Date: Mon, 14 Dec 2015 20:55:22 +0100
Message-ID: <1450122922-3174-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch removes ARPHRD_IEEE802154 from addrconf handling. In the
earlier days of 802.15.4 6LoWPAN, the interface type was ARPHRD_IEEE802154
which introduced several issues, because 802.15.4 interfaces used the
same type.

Since commit 965e613d299c ("ieee802154: 6lowpan: fix ARPHRD to
ARPHRD_6LOWPAN") we use ARPHRD_6LOWPAN for 6LoWPAN interfaces. This
patch will remove ARPHRD_IEEE802154 which is currently deadcode, because
ARPHRD_IEEE802154 doesn't reach the minimum 1280 MTU of IPv6.

Also we use 6LoWPAN EUI64 specific defines instead using link-layer
constanst from 802.15.4 link-layer header.

Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ipv6/addrconf.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5e9111d..7082fb7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -70,7 +70,7 @@
 #include <net/sock.h>
 #include <net/snmp.h>
 
-#include <net/af_ieee802154.h>
+#include <net/6lowpan.h>
 #include <net/firewire.h>
 #include <net/ipv6.h>
 #include <net/protocol.h>
@@ -1947,9 +1947,9 @@ static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
 
 static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
 {
-	if (dev->addr_len != IEEE802154_ADDR_LEN)
+	if (dev->addr_len != EUI64_ADDR_LEN)
 		return -1;
-	memcpy(eui, dev->dev_addr, 8);
+	memcpy(eui, dev->dev_addr, EUI64_ADDR_LEN);
 	eui[0] ^= 2;
 	return 0;
 }
@@ -2041,7 +2041,6 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 	case ARPHRD_IPGRE:
 		return addrconf_ifid_gre(eui, dev);
 	case ARPHRD_6LOWPAN:
-	case ARPHRD_IEEE802154:
 		return addrconf_ifid_eui64(eui, dev);
 	case ARPHRD_IEEE1394:
 		return addrconf_ifid_ieee1394(eui, dev);
@@ -3066,7 +3065,6 @@ static void addrconf_dev_config(struct net_device *dev)
 	    (dev->type != ARPHRD_FDDI) &&
 	    (dev->type != ARPHRD_ARCNET) &&
 	    (dev->type != ARPHRD_INFINIBAND) &&
-	    (dev->type != ARPHRD_IEEE802154) &&
 	    (dev->type != ARPHRD_IEEE1394) &&
 	    (dev->type != ARPHRD_TUNNEL6) &&
 	    (dev->type != ARPHRD_6LOWPAN)) {
-- 
2.6.1
