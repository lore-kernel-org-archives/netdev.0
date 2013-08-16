From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 1/6] 6lowpan: init ipv6hdr
	buffer to zero
Date: Fri, 16 Aug 2013 21:59:54 +0200
Message-ID: <1376683199-10370-2-git-send-email-alex.aring@gmail.com>
References: <1376683199-10370-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1376683199-10370-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch simplify the handling to set fields inside of struct ipv6hdr
to zero. Instead of setting some memory regions with memset to zero we
initialize the whole ipv6hdr to zero.

This is a simplification for parsing the 6lowpan header for the upcomming
patches.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 3b9d5f2..92429db 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -223,10 +223,6 @@ lowpan_uncompress_addr(struct sk_buff *skb, struct in6_addr *ipaddr,
 	if (prefcount > 0)
 		memcpy(ipaddr, prefix, prefcount);
 
-	if (prefcount + postcount < 16)
-		memset(&ipaddr->s6_addr[prefcount], 0,
-					16 - (prefcount + postcount));
-
 	if (postcount > 0) {
 		memcpy(&ipaddr->s6_addr[16 - postcount], skb->data, postcount);
 		skb_pull(skb, postcount);
@@ -723,7 +719,7 @@ frame_err:
 static int
 lowpan_process_data(struct sk_buff *skb)
 {
-	struct ipv6hdr hdr;
+	struct ipv6hdr hdr = {};
 	u8 tmp, iphc0, iphc1, num_context = 0;
 	u8 *_saddr, *_daddr;
 	int err;
@@ -868,8 +864,6 @@ lowpan_process_data(struct sk_buff *skb)
 
 		hdr.priority = ((tmp >> 2) & 0x0f);
 		hdr.flow_lbl[0] = ((tmp << 6) & 0xC0) | ((tmp >> 2) & 0x30);
-		hdr.flow_lbl[1] = 0;
-		hdr.flow_lbl[2] = 0;
 		break;
 	/*
 	 * Flow Label carried in-line
@@ -885,10 +879,6 @@ lowpan_process_data(struct sk_buff *skb)
 		break;
 	/* Traffic Class and Flow Label are elided */
 	case 3: /* 11b */
-		hdr.priority = 0;
-		hdr.flow_lbl[0] = 0;
-		hdr.flow_lbl[1] = 0;
-		hdr.flow_lbl[2] = 0;
 		break;
 	default:
 		break;
-- 
1.8.3.3


------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite!
It's a free troubleshooting tool designed for production.
Get down to code-level detail for bottlenecks, with <2% overhead. 
Download for free and get started troubleshooting in minutes. 
http://pubads.g.doubleclick.net/gampad/clk?id=48897031&iu=/4140/ostg.clktrk
