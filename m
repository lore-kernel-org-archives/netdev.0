From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 03/13] TProxy: move dst_cookie to the first cacheline in
 ipv6_pinfo
Date: Sun, 30 Aug 2009 08:52:01 +0200
Message-ID: <1253548005.12519.3.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While looking for a place to add a new bitfield in ipv6_pinfo,
I've found a 32 bit hole (in 64 bit mode) at the beginning of the struct.
Since dst_cookie is used in the output fastpath, I've moved this field to
fill the hole. The original place of dst_cookie is now empty, but
can become a place to add further fields to the struct.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 include/linux/ipv6.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index c662efa..be4c9c6 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -285,6 +285,7 @@ struct ipv6_pinfo {
 	struct in6_addr 	saddr;
 	struct in6_addr 	rcv_saddr;
 	struct in6_addr		daddr;
+	__u32			dst_cookie;
 	struct in6_pktinfo	sticky_pktinfo;
 	struct in6_addr		*daddr_cache;
 #ifdef CONFIG_IPV6_SUBTREES
@@ -348,7 +349,7 @@ struct ipv6_pinfo {
 						 */
 	__u8			tclass;
 
-	__u32			dst_cookie;
+	/* 32 bits hole on 64 bit platforms */
 
 	struct ipv6_mc_socklist	*ipv6_mc_list;
 	struct ipv6_ac_socklist	*ipv6_ac_list;
-- 
1.6.0.4

