From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] tunnel: use the correct endian for some fields
Date: Thu, 15 Nov 2012 16:51:22 +0800
Message-ID: <1352969482-29836-1-git-send-email-amwang@redhat.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38167 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993226Ab2KOIvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 03:51:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fengguang reported:

net/ipv6/ip6_tunnel.c:1571:33: sparse: incorrect type in assignment (different base types)
net/ipv6/ip6_tunnel.c:1571:33:    expected restricted __be32 [usertype] flowinfo
net/ipv6/ip6_tunnel.c:1571:33:    got unsigned int

for these fields, we need to use the correct endian wrapers.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 64686e1..54477d8 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -864,7 +864,7 @@ static void ipip_netlink_parms(struct nlattr *data[],
 		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
 
 	if (data[IFLA_IPTUN_LOCAL])
-		parms->iph.saddr = nla_get_u32(data[IFLA_IPTUN_LOCAL]);
+		parms->iph.saddr = nla_get_be32(data[IFLA_IPTUN_LOCAL]);
 
 	if (data[IFLA_IPTUN_REMOTE])
 		parms->iph.daddr = nla_get_u32(data[IFLA_IPTUN_REMOTE]);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ab4d056..bf3a549 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1568,7 +1568,7 @@ static void ip6_tnl_netlink_parms(struct nlattr *data[],
 		parms->encap_limit = nla_get_u8(data[IFLA_IPTUN_ENCAP_LIMIT]);
 
 	if (data[IFLA_IPTUN_FLOWINFO])
-		parms->flowinfo = nla_get_u32(data[IFLA_IPTUN_FLOWINFO]);
+		parms->flowinfo = nla_get_be32(data[IFLA_IPTUN_FLOWINFO]);
 
 	if (data[IFLA_IPTUN_FLAGS])
 		parms->flags = nla_get_u32(data[IFLA_IPTUN_FLAGS]);
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 7bd2a06..e137750 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1240,7 +1240,7 @@ static void ipip6_netlink_parms(struct nlattr *data[],
 		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
 
 	if (data[IFLA_IPTUN_LOCAL])
-		parms->iph.saddr = nla_get_u32(data[IFLA_IPTUN_LOCAL]);
+		parms->iph.saddr = nla_get_be32(data[IFLA_IPTUN_LOCAL]);
 
 	if (data[IFLA_IPTUN_REMOTE])
 		parms->iph.daddr = nla_get_u32(data[IFLA_IPTUN_REMOTE]);
@@ -1337,7 +1337,7 @@ static int ipip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
 		       !!(parm->iph.frag_off & htons(IP_DF))) ||
-	    nla_put_u16(skb, IFLA_IPTUN_FLAGS, parm->i_flags))
+	    nla_put_be16(skb, IFLA_IPTUN_FLAGS, parm->i_flags))
 		goto nla_put_failure;
 	return 0;
 
