From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 3/6] 6lowpan: introduce
	lowpan_fetch_skb function
Date: Fri, 16 Aug 2013 21:59:56 +0200
Message-ID: <1376683199-10370-4-git-send-email-alex.aring@gmail.com>
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

This patch adds a helper function to parse the ipv6 header to a
6lowpan header in stream.

This function checks first if we can pull data with a specific
length from a skb. If this seems to be okay, we copy skb data to
a destination pointer and run skb_pull.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
---
 net/ieee802154/6lowpan.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index 4b8f917..a636545 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -230,4 +230,16 @@
 					dest = 16 bit inline */
 #define LOWPAN_NHC_UDP_CS_P_11	0xF3 /* source & dest = 0xF0B + 4bit inline */
 
+static inline bool lowpan_fetch_skb(struct sk_buff *skb,
+		void *data, const unsigned int len)
+{
+	if (unlikely(!pskb_may_pull(skb, len)))
+		return true;
+
+	skb_copy_from_linear_data(skb, data, len);
+	skb_pull(skb, len);
+
+	return false;
+}
+
 #endif /* __6LOWPAN_H__ */
-- 
1.8.3.3


------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite!
It's a free troubleshooting tool designed for production.
Get down to code-level detail for bottlenecks, with <2% overhead. 
Download for free and get started troubleshooting in minutes. 
http://pubads.g.doubleclick.net/gampad/clk?id=48897031&iu=/4140/ostg.clktrk
