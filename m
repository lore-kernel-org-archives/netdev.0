From: akpm@osdl.org
Subject: [patch 10/10] ip_conntrack build fix
Date: Mon, 24 Jan 2005 18:57:23 -0800
Message-ID: <200501250257.j0P2vpl20304@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        benoit.boissinot@ens-lyon.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

Without the following patch, it doesn't compile with ip_conntrack and
without ip_nat.

In file included from net/ipv4/netfilter/ip_conntrack_standalone.c:34:
include/linux/netfilter_ipv4/ip_conntrack.h:306: error: parameter `manip' has incomplete type
include/linux/netfilter_ipv4/ip_conntrack.h: In function `ip_nat_initialized':
include/linux/netfilter_ipv4/ip_conntrack.h:307: error: `IP_NAT_MANIP_SRC' undeclared (first use in this function)

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/include/linux/netfilter_ipv4/ip_conntrack.h |    2 ++
 1 files changed, 2 insertions(+)

diff -puN include/linux/netfilter_ipv4/ip_conntrack.h~ip_conntrack-build-fix include/linux/netfilter_ipv4/ip_conntrack.h
--- 25/include/linux/netfilter_ipv4/ip_conntrack.h~ip_conntrack-build-fix	2005-01-24 18:55:47.956006416 -0800
+++ 25-akpm/include/linux/netfilter_ipv4/ip_conntrack.h	2005-01-24 18:55:47.960005808 -0800
@@ -301,6 +301,7 @@ struct ip_conntrack_stat
 
 #define CONNTRACK_STAT_INC(count) (__get_cpu_var(ip_conntrack_stat).count++)
 
+#ifdef CONFIG_IP_NF_NAT_NEEDED
 static inline int ip_nat_initialized(struct ip_conntrack *conntrack,
 				     enum ip_nat_manip_type manip)
 {
@@ -308,5 +309,6 @@ static inline int ip_nat_initialized(str
 		return test_bit(IPS_SRC_NAT_DONE_BIT, &conntrack->status);
 	return test_bit(IPS_DST_NAT_DONE_BIT, &conntrack->status);
 }
+#endif /* CONFIG_IP_NF_NAT_NEEDED */
 #endif /* __KERNEL__ */
 #endif /* _IP_CONNTRACK_H */
_
