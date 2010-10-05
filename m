From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] ipv6: make __ipv6_isatap_ifid static
Date: Tue, 5 Oct 2010 15:17:53 +0900
Message-ID: <20101005151753.363121b8@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47810 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753967Ab0JEGR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 02:17:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another exported symbol only used in one file

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/addrconf.h |    2 --
 net/ipv6/addrconf.c    |    3 +--
 2 files changed, 1 insertion(+), 4 deletions(-)

--- a/include/net/addrconf.h	2010-10-02 09:04:22.700929104 +0900
+++ b/include/net/addrconf.h	2010-10-02 09:11:00.651004530 +0900
@@ -276,8 +276,6 @@ static inline int ipv6_addr_is_ll_all_ro
 		(addr->s6_addr32[3] ^ htonl(0x00000002))) == 0;
 }
 
-extern int __ipv6_isatap_ifid(u8 *eui, __be32 addr);
-
 static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
 {
 	return (addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE);
--- a/net/ipv6/addrconf.c	2010-10-02 09:04:22.720901336 +0900
+++ b/net/ipv6/addrconf.c	2010-10-02 09:05:09.031021195 +0900
@@ -1544,7 +1544,7 @@ static int addrconf_ifid_infiniband(u8 *
 	return 0;
 }
 
-int __ipv6_isatap_ifid(u8 *eui, __be32 addr)
+static int __ipv6_isatap_ifid(u8 *eui, __be32 addr)
 {
 	if (addr == 0)
 		return -1;
@@ -1560,7 +1560,6 @@ int __ipv6_isatap_ifid(u8 *eui, __be32 a
 	memcpy(eui + 4, &addr, 4);
 	return 0;
 }
-EXPORT_SYMBOL(__ipv6_isatap_ifid);
 
 static int addrconf_ifid_sit(u8 *eui, struct net_device *dev)
 {
