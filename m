From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 2/2] 6lowpan: duplicate
	definition of IEEE802154_ALEN
Date: Thu, 26 Apr 2012 13:35:51 +0400
Message-ID: <1335432951-17340-3-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1335432951-17340-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1335432951-17340-1-git-send-email-alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The same macros is defined in 'include/net/af_ieee802154.h' and is called
IEEE802154_ADDR_LEN. No need another one, so remove it.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c |    4 ++--
 net/ieee802154/6lowpan.h |    3 ---
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index f406ac8..32eb417 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -196,7 +196,7 @@ lowpan_compress_addr_64(u8 **hc06_ptr, u8 shift, const struct in6_addr *ipaddr,
 static void
 lowpan_uip_ds6_set_addr_iid(struct in6_addr *ipaddr, unsigned char *lladdr)
 {
-	memcpy(&ipaddr->s6_addr[8], lladdr, IEEE802154_ALEN);
+	memcpy(&ipaddr->s6_addr[8], lladdr, IEEE802154_ADDR_LEN);
 	/* second bit-flip (Universe/Local) is done according RFC2464 */
 	ipaddr->s6_addr[8] ^= 0x02;
 }
@@ -221,7 +221,7 @@ lowpan_uncompress_addr(struct sk_buff *skb, struct in6_addr *ipaddr,
 
 	if (lladdr)
 		lowpan_raw_dump_inline(__func__, "linklocal address",
-						lladdr,	IEEE802154_ALEN);
+						lladdr,	IEEE802154_ADDR_LEN);
 	if (prefcount > 0)
 		memcpy(ipaddr, prefix, prefcount);
 
diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index aeff3f3..8c2251f 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -53,9 +53,6 @@
 #ifndef __6LOWPAN_H__
 #define __6LOWPAN_H__
 
-/* need to know address length to manipulate with it */
-#define IEEE802154_ALEN		8
-
 #define UIP_802154_SHORTADDR_LEN	2  /* compressed ipv6 address length */
 #define UIP_IPH_LEN			40 /* ipv6 fixed header size */
 #define UIP_PROTO_UDP			17 /* ipv6 next header value for UDP */
-- 
1.7.2.3


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
