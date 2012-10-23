From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH net-next 09/15] 6lowpan: add a new
	parameter in sysfs to turn on/off ACK request at MAC layer
Date: Tue, 23 Oct 2012 00:09:51 -0400
Message-ID: <1350965397-12384-10-git-send-email-tony.cheneau@amnesiak.org>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1350965397-12384-1-git-send-email-tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
---
 net/ieee802154/6lowpan.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 24b83fa..f8fcdae 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -62,6 +62,8 @@
 
 #include "6lowpan.h"
 
+static bool req_802154_ack;
+
 /* TTL uncompression values */
 static const u8 lowpan_ttl_values[] = {0, 1, 64, 255};
 
@@ -596,7 +598,8 @@ static int lowpan_header_create(struct sk_buff *skb,
 			memcpy(&(da.hwaddr), daddr, 8);
 
 			/* request acknowledgment */
-			mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
+			if (req_802154_ack)
+				mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
 		}
 
 		return dev_hard_header(skb, lowpan_dev_info(dev)->real_dev,
@@ -1366,6 +1369,10 @@ static void __exit lowpan_cleanup_module(void)
 }
 
 module_init(lowpan_init_module);
+
+module_param(req_802154_ack, bool, 0644);
+MODULE_PARM_DESC(req_802154_ack, "request link-layer (i.e. IEEE 802.15.4) acknowledgments");
+
 module_exit(lowpan_cleanup_module);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_RTNL_LINK("lowpan");
-- 
1.7.8.6


------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_sfd2d_oct
