From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH v2 net-next 10/12] 6lowpan: obtain
	IEEE802.15.4 sequence number from the MAC layer
Date: Mon, 25 Mar 2013 23:59:30 -0400
Message-ID: <1364270372-19430-11-git-send-email-tony.cheneau@amnesiak.org>
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

Sets the sequence number in the frame format. Without this fix, the sequence
number is always set to 0. This makes trafic analysis very hard.

Signed-off-by: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index f952451..d1d4ee6 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -573,6 +573,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 	 */
 	{
 		mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
+		mac_cb(skb)->seq = ieee802154_mlme_ops(dev)->get_dsn(dev);
 
 		/* prepare wpan address data */
 		sa.addr_type = IEEE802154_ADDR_LONG;
@@ -1127,6 +1128,12 @@ static u16 lowpan_get_short_addr(const struct net_device *dev)
 	return ieee802154_mlme_ops(real_dev)->get_short_addr(real_dev);
 }
 
+static u8 lowpan_get_dsn(const struct net_device *dev)
+{
+	struct net_device *real_dev = lowpan_dev_info(dev)->real_dev;
+	return ieee802154_mlme_ops(real_dev)->get_dsn(real_dev);
+}
+
 static struct header_ops lowpan_header_ops = {
 	.create	= lowpan_header_create,
 };
@@ -1140,6 +1147,7 @@ static struct ieee802154_mlme_ops lowpan_mlme = {
 	.get_pan_id = lowpan_get_pan_id,
 	.get_phy = lowpan_get_phy,
 	.get_short_addr = lowpan_get_short_addr,
+	.get_dsn = lowpan_get_dsn,
 };
 
 static void lowpan_setup(struct net_device *dev)
-- 
1.7.12.4


------------------------------------------------------------------------------
Own the Future-Intel&reg; Level Up Game Demo Contest 2013
Rise to greatness in Intel's independent game demo contest.
Compete for recognition, cash, and the chance to get your game 
on Steam. $5K grand prize plus 10 genre and skill prizes. 
Submit your demo by 6/6/13. http://p.sf.net/sfu/intel_levelupd2d
