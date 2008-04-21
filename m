From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make __ipv6_isatap_ifid() static
Date: Mon, 21 Apr 2008 11:48:18 +0300
Message-ID: <20080421084818.GN26897@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:41014 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756849AbYDUIsr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 04:48:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__ipv6_isatap_ifid() can become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/net/addrconf.h |    2 --
 net/ipv6/addrconf.c    |    3 +--
 2 files changed, 1 insertion(+), 4 deletions(-)

\2064125a01db3d6716f93f15309fa98f75b74dd8 diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 0a2f037..8e021c1 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -224,8 +224,6 @@ static inline int ipv6_addr_is_ll_all_routers(const struct in6_addr *addr)
 		(addr->s6_addr32[3] ^ htonl(0x00000002))) == 0);
 }
 
-extern int __ipv6_isatap_ifid(u8 *eui, __be32 addr);
-
 static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
 {
 	return ((addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE));
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8a0fd40..936db47 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1492,7 +1492,7 @@ static int addrconf_ifid_infiniband(u8 *eui, struct net_device *dev)
 	return 0;
 }
 
-int __ipv6_isatap_ifid(u8 *eui, __be32 addr)
+static int __ipv6_isatap_ifid(u8 *eui, __be32 addr)
 {
 	eui[0] = (ipv4_is_zeronet(addr) || ipv4_is_private_10(addr) ||
 		  ipv4_is_loopback(addr) || ipv4_is_linklocal_169(addr) ||
@@ -1506,7 +1506,6 @@ int __ipv6_isatap_ifid(u8 *eui, __be32 addr)
 	memcpy(eui + 4, &addr, 4);
 	return 0;
 }
-EXPORT_SYMBOL(__ipv6_isatap_ifid);
 
 static int addrconf_ifid_sit(u8 *eui, struct net_device *dev)
 {

