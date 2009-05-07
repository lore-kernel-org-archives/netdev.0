From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH]ipv6:use ipv6_addr_type instead of __ipv6_addr_type
Date: Thu, 07 May 2009 15:47:38 +0800
Message-ID: <4A02921A.1090200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55952 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753897AbZEGHqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 03:46:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although the function of these two functions are the same,we should use the
encapsulation function of __ipv6_addr_type

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 net/ipv6/addrconf.c |    4 ++--
 net/ipv6/datagram.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a8218bc..01b7a83 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1126,7 +1126,7 @@ int ipv6_dev_get_saddr(struct net *net, struct net_device *dst_dev,
 	struct net_device *dev;
 	int dst_type;
 
-	dst_type = __ipv6_addr_type(daddr);
+	dst_type = ipv6_addr_type(daddr);
 	dst.addr = daddr;
 	dst.ifindex = dst_dev ? dst_dev->ifindex : 0;
 	dst.scope = __ipv6_addr_src_scope(dst_type);
@@ -1181,7 +1181,7 @@ int ipv6_dev_get_saddr(struct net *net, struct net_device *dst_dev,
 			    (!(score->ifa->flags & IFA_F_OPTIMISTIC)))
 				continue;
 
-			score->addr_type = __ipv6_addr_type(&score->ifa->addr);
+			score->addr_type = ipv6_addr_type(&score->ifa->addr);
 
 			if (unlikely(score->addr_type == IPV6_ADDR_ANY ||
 				     score->addr_type & IPV6_ADDR_MULTICAST)) {
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index e2bdc6d..7ea5c77 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -537,7 +537,7 @@ int datagram_send_ctl(struct net *net,
 				fl->oif = src_info->ipi6_ifindex;
 			}
 
-			addr_type = __ipv6_addr_type(&src_info->ipi6_addr);
+			addr_type = ipv6_addr_type(&src_info->ipi6_addr);
 
 			if (fl->oif) {
 				dev = dev_get_by_index(net, fl->oif);
-- 
1.6.0.3


-- 
Regards
Yang Hongyang
