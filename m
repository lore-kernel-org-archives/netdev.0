From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH net-next 01/15] 6lowpan:
	lowpan_is_iid_16_bit_compressable() does not detect
	compressable address correctly
Date: Tue, 23 Oct 2012 00:09:43 -0400
Message-ID: <1350965397-12384-2-git-send-email-tony.cheneau@amnesiak.org>
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

The current test is not RFC6282 compliant. The same issue has been found
out and fixed in Contiki. This patch is basicaly a port of their fix.

Signed-off-by: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
---
 net/ieee802154/6lowpan.h |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index 8c2251f..efd1a57 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -87,14 +87,16 @@
 #define is_addr_link_local(a) (((a)->s6_addr16[0]) == 0x80FE)
 
 /*
- * check whether we can compress the IID to 16 bits,
- * it's possible for unicast adresses with first 49 bits are zero only.
- */
+* check whether we can compress the IID to 16 bits,
+* it's possible for unicast adresses with first 49 bits are zero only.
+*/
 #define lowpan_is_iid_16_bit_compressable(a)	\
 	((((a)->s6_addr16[4]) == 0) &&		\
-	 (((a)->s6_addr16[5]) == 0) &&		\
-	 (((a)->s6_addr16[6]) == 0) &&		\
-	 ((((a)->s6_addr[14]) & 0x80) == 0))
+	 (((a)->s6_addr[10]) == 0) &&		\
+	 (((a)->s6_addr[11]) == 0xff) &&	\
+	 (((a)->s6_addr[12]) == 0xfe) &&	\
+	 (((a)->s6_addr[13]) == 0))
+
 
 /* multicast address */
 #define is_addr_mcast(a) (((a)->s6_addr[0]) == 0xFF)
-- 
1.7.8.6


------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_sfd2d_oct
