From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] 6lowpan: use stack buffer instead
	of heap
Date: Tue,  5 Feb 2013 21:23:43 +0100
Message-ID: <1360095824-12538-2-git-send-email-alex.aring@gmail.com>
References: <1360095824-12538-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1360095824-12538-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

head buffer is only temporary available in lowpan_header_create.
So it's not necessary to put it on the heap.

Also fixed a comment codestyle issue.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index f651da6..2bc5e8f 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -377,17 +377,14 @@ static int lowpan_header_create(struct sk_buff *skb,
 	struct ipv6hdr *hdr;
 	const u8 *saddr = _saddr;
 	const u8 *daddr = _daddr;
-	u8 *head;
+	u8 head[100];
 	struct ieee802154_addr sa, da;
 
+	/* TODO:
+	 * if this package isn't ipv6 one, where should it be routed?
+	 */
 	if (type != ETH_P_IPV6)
 		return 0;
-		/* TODO:
-		 * if this package isn't ipv6 one, where should it be routed?
-		 */
-	head = kzalloc(100, GFP_KERNEL);
-	if (head == NULL)
-		return -ENOMEM;
 
 	hdr = ipv6_hdr(skb);
 	hc06_ptr = head + 2;
@@ -561,8 +558,6 @@ static int lowpan_header_create(struct sk_buff *skb,
 	skb_pull(skb, sizeof(struct ipv6hdr));
 	memcpy(skb_push(skb, hc06_ptr - head), head, hc06_ptr - head);
 
-	kfree(head);
-
 	lowpan_raw_dump_table(__func__, "raw skb data dump", skb->data,
 				skb->len);
 
-- 
1.8.1.2


------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
