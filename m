From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] wpan: use stack buffer instead of
	heap
Date: Tue,  5 Feb 2013 21:23:44 +0100
Message-ID: <1360095824-12538-3-git-send-email-alex.aring@gmail.com>
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

head buffer is only temporary available in mac802154_header_create.
So it's not necessary to put it on the heap.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/mac802154/wpan.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 98c867b..d20c6d3 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -137,16 +137,12 @@ static int mac802154_header_create(struct sk_buff *skb,
 	struct ieee802154_addr dev_addr;
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
 	int pos = 2;
-	u8 *head;
+	u8 head[MAC802154_FRAME_HARD_HEADER_LEN];
 	u16 fc;
 
 	if (!daddr)
 		return -EINVAL;
 
-	head = kzalloc(MAC802154_FRAME_HARD_HEADER_LEN, GFP_KERNEL);
-	if (head == NULL)
-		return -ENOMEM;
-
 	head[pos++] = mac_cb(skb)->seq; /* DSN/BSN */
 	fc = mac_cb_type(skb);
 
@@ -210,7 +206,6 @@ static int mac802154_header_create(struct sk_buff *skb,
 	head[1] = fc >> 8;
 
 	memcpy(skb_push(skb, pos), head, pos);
-	kfree(head);
 
 	return pos;
 }
-- 
1.8.1.2


------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
