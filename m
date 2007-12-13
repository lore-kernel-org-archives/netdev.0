From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.25 2/8] include/net: Use ipv4_is_<type>
Date: Thu, 13 Dec 2007 15:38:55 -0800
Message-ID: <1197589141-7020-2-git-send-email-joe@perches.com>
References: <1197589141-7020-1-git-send-email-joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4211 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754967AbXLMXjF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 18:39:05 -0500
Received: from localhost.localdomain (192-168-1-128.LABridge.com [192.168.1.128] (may be forged))
	by perches.com (8.9.3/8.9.3) with ESMTP id OAA17666
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 14:52:22 -0800
In-Reply-To: <1197589141-7020-1-git-send-email-joe@perches.com>
Message-Id: <40bae850207de9257479a535ea5ab4e7d1cdeab5.1197432867.git.joe@perches.com>
In-Reply-To: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
References: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/addrconf.h |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index c56827d..1c3a560 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -252,10 +252,12 @@ static inline int ipv6_addr_is_ll_all_routers(const struct in6_addr *addr)
 
 static inline int ipv6_isatap_eui64(u8 *eui, __be32 addr)
 {
-	eui[0] = (ZERONET(addr) || PRIVATE_10(addr) || LOOPBACK(addr) ||
-		  LINKLOCAL_169(addr) || PRIVATE_172(addr) || TEST_192(addr) ||
-		  ANYCAST_6TO4(addr) || PRIVATE_192(addr) || TEST_198(addr) ||
-		  MULTICAST(addr) || BADCLASS(addr)) ? 0x00 : 0x02;
+	eui[0] = (ipv4_is_zeronet(addr) || ipv4_is_private_10(addr) ||
+		  ipv4_is_loopback(addr) || ipv4_is_linklocal_169(addr) ||
+		  ipv4_is_private_172(addr) || ipv4_is_test_192(addr) ||
+		  ipv4_is_anycast_6to4(addr) || ipv4_is_private_192(addr) ||
+		  ipv4_is_test_198(addr) || ipv4_is_multicast(addr) ||
+		  ipv4_is_badclass(addr)) ? 0x00 : 0x02;
 	eui[1] = 0;
 	eui[2] = 0x5E;
 	eui[3] = 0xFE;
-- 
1.5.3.7.949.g2221a6

