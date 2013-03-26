From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH v2 net-next 03/12] 6lowpan: always
	enable link-layer acknowledgments
Date: Mon, 25 Mar 2013 23:59:23 -0400
Message-ID: <1364270372-19430-4-git-send-email-tony.cheneau@amnesiak.org>
References: <1364270372-19430-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364270372-19430-1-git-send-email-tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This feature is especially important when using fragmentation, because
the reassembly mechanism cannot recover from the loss of a fragment.

Note that some hardware ignore this flag and not will not transmit
acknowledgments even if this is set.

Signed-off-by: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 9f53904..e7f61de 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -584,6 +584,10 @@ static int lowpan_header_create(struct sk_buff *skb,
 
 		mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
 
+		/* request acknowledgment when possible */
+		if (!lowpan_is_addr_broadcast(daddr))
+			mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
+
 		return dev_hard_header(skb, lowpan_dev_info(dev)->real_dev,
 				type, (void *)&da, (void *)&sa, skb->len);
 	}
-- 
1.7.12.4


------------------------------------------------------------------------------
Own the Future-Intel&reg; Level Up Game Demo Contest 2013
Rise to greatness in Intel's independent game demo contest.
Compete for recognition, cash, and the chance to get your game 
on Steam. $5K grand prize plus 10 genre and skill prizes. 
Submit your demo by 6/6/13. http://p.sf.net/sfu/intel_levelupd2d
