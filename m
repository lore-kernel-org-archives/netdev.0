From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 1/4] 6lowpan: remove
	unnecessary set of headers
Date: Wed, 30 Oct 2013 09:18:21 +0100
Message-ID: <1383121104-2515-2-git-send-email-alex.aring@gmail.com>
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

On receiving side we don't need to set any headers in skb because the
6LoWPAN layer do not access it. Currently these values will set twice
after calling netif_rx.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index fde90e6..6d67784 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -737,7 +737,6 @@ static int lowpan_skb_deliver(struct sk_buff *skb, struct ipv6hdr *hdr)
 		return -ENOMEM;
 
 	skb_push(new, sizeof(struct ipv6hdr));
-	skb_reset_network_header(new);
 	skb_copy_to_linear_data(new, hdr, sizeof(struct ipv6hdr));
 
 	new->protocol = htons(ETH_P_IPV6);
@@ -1059,7 +1058,6 @@ lowpan_process_data(struct sk_buff *skb)
 		skb = new;
 
 		skb_push(skb, sizeof(struct udphdr));
-		skb_reset_transport_header(skb);
 		skb_copy_to_linear_data(skb, &uh, sizeof(struct udphdr));
 
 		lowpan_raw_dump_table(__func__, "raw UDP header dump",
@@ -1323,8 +1321,6 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 
 		/* Pull off the 1-byte of 6lowpan header. */
 		skb_pull(local_skb, 1);
-		skb_reset_network_header(local_skb);
-		skb_set_transport_header(local_skb, sizeof(struct ipv6hdr));
 
 		lowpan_give_skb_to_devices(local_skb);
 
-- 
1.8.4.2


------------------------------------------------------------------------------
Android is increasing in popularity, but the open development platform that
developers love is also attractive to malware creators. Download this white
paper to learn more about secure code signing practices that can help keep
Android apps secure.
http://pubads.g.doubleclick.net/gampad/clk?id=65839951&iu=/4140/ostg.clktrk
