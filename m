From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 2/4] 6lowpan: set and use
	mac_len for mac header length
Date: Wed, 30 Oct 2013 09:18:22 +0100
Message-ID: <1383121104-2515-3-git-send-email-alex.aring@gmail.com>
References: <1383121104-2515-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1383121104-2515-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Set the mac header length while creating the 802.15.4 mac header.

Drop the function for recalculate mac header length in upper layers
which was static and works for intra pan communication only.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 13 +------------
 net/mac802154/wpan.c     |  2 ++
 2 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 6d67784..e6db1f5 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1100,17 +1100,6 @@ static int lowpan_set_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-static int lowpan_get_mac_header_length(struct sk_buff *skb)
-{
-	/*
-	 * Currently long addressing mode is supported only, so the overall
-	 * header size is 21:
-	 * FC SeqNum DPAN DA  SA  Sec
-	 * 2  +  1  +  2 + 8 + 8 + 0  = 21
-	 */
-	return 21;
-}
-
 static int
 lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
 			int mlen, int plen, int offset, int type)
@@ -1150,7 +1139,7 @@ lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
 	int  err, header_length, payload_length, tag, offset = 0;
 	u8 head[5];
 
-	header_length = lowpan_get_mac_header_length(skb);
+	header_length = skb->mac_len;
 	payload_length = skb->len - header_length;
 	tag = lowpan_dev_info(dev)->fragment_tag++;
 
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 2ca2f4d..e24bcf9 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -208,6 +208,8 @@ static int mac802154_header_create(struct sk_buff *skb,
 	head[1] = fc >> 8;
 
 	memcpy(skb_push(skb, pos), head, pos);
+	skb_reset_mac_header(skb);
+	skb->mac_len = pos;
 
 	return pos;
 }
-- 
1.8.4.2


------------------------------------------------------------------------------
Android is increasing in popularity, but the open development platform that
developers love is also attractive to malware creators. Download this white
paper to learn more about secure code signing practices that can help keep
Android apps secure.
http://pubads.g.doubleclick.net/gampad/clk?id=65839951&iu=/4140/ostg.clktrk
