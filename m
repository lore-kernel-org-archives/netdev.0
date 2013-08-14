From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCHv2 net-next] 6lowpan: handle only real
	link-local addresses
Date: Wed, 14 Aug 2013 13:01:07 +0200
Message-ID: <1376478067-3371-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

A link-local address isn't fe80::/10 it's fe80::/64
see http://tools.ietf.org/html/rfc4291#section-2.5.6
for more details.

Also fix a comment issue "local link" -> "link-local"

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
---
v2:
 - Add "net-next" tag

 net/ieee802154/6lowpan.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index 4b8f917..61f0ce9 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -83,8 +83,11 @@
 #define ipaddr_prefixcmp(addr1, addr2, length) \
 	(memcmp(addr1, addr2, length >> 3) == 0)
 
-/* local link, i.e. FE80::/10 */
-#define is_addr_link_local(a) (((a)->s6_addr16[0]) == htons(0xFE80))
+/* link-local, i.e. FE80::/64 */
+#define is_addr_link_local(a) (((a)->s6_addr16[0]) == htons(0xFE80) &&	\
+		(((a)->s6_addr16[1]) == 0) &&	\
+		(((a)->s6_addr16[2]) == 0) &&	\
+		(((a)->s6_addr16[3]) == 0))
 
 /*
  * check whether we can compress the IID to 16 bits,
-- 
1.8.3.3


------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite!
It's a free troubleshooting tool designed for production.
Get down to code-level detail for bottlenecks, with <2% overhead. 
Download for free and get started troubleshooting in minutes. 
http://pubads.g.doubleclick.net/gampad/clk?id=48897031&iu=/4140/ostg.clktrk
