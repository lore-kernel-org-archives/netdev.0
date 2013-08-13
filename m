From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH] 6lowpan: handle only real link-local addresses
Date: Tue, 13 Aug 2013 23:53:26 +0200
Message-ID: <1376430813-30982-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:51432 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758094Ab3HMVtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 17:49:49 -0400
Received: by mail-ea0-f178.google.com with SMTP id a15so4327792eae.23
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 14:49:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A link-local address isn't fe80::/10 it's fe80::/64
see http://tools.ietf.org/html/rfc4291#section-2.5.6
for more details.

Also fix a comment issue "local link" -> "link-local"

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
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
