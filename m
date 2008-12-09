From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [RFC][PATCH 2/3]ipv6:fix the return interface index when get it while
 no message is received
Date: Tue, 09 Dec 2008 15:10:52 +0800
Message-ID: <493E19FC.1080609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63654 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751696AbYLIHJV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2008 02:09:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When get receiving interface index while no message is received,
the the value seted with setsockopt() should be returned.

RFC 3542:
   Issuing getsockopt() for the above options will return the sticky
   option value i.e., the value set with setsockopt().  If no sticky
   option value has been set getsockopt() will return the following
   values:

   -  For the IPV6_PKTINFO option, it will return an in6_pktinfo
      structure with ipi6_addr being in6addr_any and ipi6_ifindex being
      zero.

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>
---
 net/ipv6/ipv6_sockglue.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index fc80401..4770bd9 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -938,8 +938,8 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		} else {
 			if (np->rxopt.bits.rxinfo) {
 				struct in6_pktinfo src_info;
-				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif : sk->sk_bound_dev_if;
-				ipv6_addr_copy(&src_info.ipi6_addr, &np->daddr);
+				src_info.ipi6_ifindex = np->sticky_pktinfo.ipi6_ifindex;
+				ipv6_addr_copy(&src_info.ipi6_addr, &(np->sticky_pktinfo.ipi6_addr));
 				put_cmsg(&msg, SOL_IPV6, IPV6_PKTINFO, sizeof(src_info), &src_info);
 			}
 			if (np->rxopt.bits.rxhlim) {
@@ -948,8 +948,8 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			}
 			if (np->rxopt.bits.rxoinfo) {
 				struct in6_pktinfo src_info;
-				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif : sk->sk_bound_dev_if;
-				ipv6_addr_copy(&src_info.ipi6_addr, &np->daddr);
+				src_info.ipi6_ifindex = np->sticky_pktinfo.ipi6_ifindex;
+				ipv6_addr_copy(&src_info.ipi6_addr, &(np->sticky_pktinfo.ipi6_addr));
 				put_cmsg(&msg, SOL_IPV6, IPV6_2292PKTINFO, sizeof(src_info), &src_info);
 			}
 			if (np->rxopt.bits.rxohlim) {
-- 
1.6.0.1
