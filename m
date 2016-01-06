From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net 1/3] ipv4: fix endianness warnings in ip_tunnel_core.c
Date: Wed,  6 Jan 2016 17:22:45 -0500
Message-ID: <1452118967-32123-2-git-send-email-lrichard@redhat.com>
References: <1452118967-32123-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36433 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653AbcAFWWs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 17:22:48 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 5571B4F638
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 22:22:48 +0000 (UTC)
Received: from dhcp129-205.rdu.redhat.com (dhcp129-10.rdu.redhat.com [10.13.129.10])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u06MMlZo005846
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2016 17:22:48 -0500
In-Reply-To: <1452118967-32123-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eliminate endianness mismatch warnings (reported by sparse) in this file by
using appropriate nla_put_*()/nla_get_*() calls.

Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 net/ipv4/ip_tunnel_core.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 6cb9009..bf70c1c 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -251,7 +251,7 @@ static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
 	tun_info = lwt_tun_info(new_state);
 
 	if (tb[LWTUNNEL_IP_ID])
-		tun_info->key.tun_id = nla_get_u64(tb[LWTUNNEL_IP_ID]);
+		tun_info->key.tun_id = nla_get_be64(tb[LWTUNNEL_IP_ID]);
 
 	if (tb[LWTUNNEL_IP_DST])
 		tun_info->key.u.ipv4.dst = nla_get_be32(tb[LWTUNNEL_IP_DST]);
@@ -266,7 +266,7 @@ static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
 		tun_info->key.tos = nla_get_u8(tb[LWTUNNEL_IP_TOS]);
 
 	if (tb[LWTUNNEL_IP_FLAGS])
-		tun_info->key.tun_flags = nla_get_u16(tb[LWTUNNEL_IP_FLAGS]);
+		tun_info->key.tun_flags = nla_get_be16(tb[LWTUNNEL_IP_FLAGS]);
 
 	tun_info->mode = IP_TUNNEL_INFO_TX;
 	tun_info->options_len = 0;
@@ -281,12 +281,12 @@ static int ip_tun_fill_encap_info(struct sk_buff *skb,
 {
 	struct ip_tunnel_info *tun_info = lwt_tun_info(lwtstate);
 
-	if (nla_put_u64(skb, LWTUNNEL_IP_ID, tun_info->key.tun_id) ||
+	if (nla_put_be64(skb, LWTUNNEL_IP_ID, tun_info->key.tun_id) ||
 	    nla_put_be32(skb, LWTUNNEL_IP_DST, tun_info->key.u.ipv4.dst) ||
 	    nla_put_be32(skb, LWTUNNEL_IP_SRC, tun_info->key.u.ipv4.src) ||
 	    nla_put_u8(skb, LWTUNNEL_IP_TOS, tun_info->key.tos) ||
 	    nla_put_u8(skb, LWTUNNEL_IP_TTL, tun_info->key.ttl) ||
-	    nla_put_u16(skb, LWTUNNEL_IP_FLAGS, tun_info->key.tun_flags))
+	    nla_put_be16(skb, LWTUNNEL_IP_FLAGS, tun_info->key.tun_flags))
 		return -ENOMEM;
 
 	return 0;
@@ -346,7 +346,7 @@ static int ip6_tun_build_state(struct net_device *dev, struct nlattr *attr,
 	tun_info = lwt_tun_info(new_state);
 
 	if (tb[LWTUNNEL_IP6_ID])
-		tun_info->key.tun_id = nla_get_u64(tb[LWTUNNEL_IP6_ID]);
+		tun_info->key.tun_id = nla_get_be64(tb[LWTUNNEL_IP6_ID]);
 
 	if (tb[LWTUNNEL_IP6_DST])
 		tun_info->key.u.ipv6.dst = nla_get_in6_addr(tb[LWTUNNEL_IP6_DST]);
@@ -361,7 +361,7 @@ static int ip6_tun_build_state(struct net_device *dev, struct nlattr *attr,
 		tun_info->key.tos = nla_get_u8(tb[LWTUNNEL_IP6_TC]);
 
 	if (tb[LWTUNNEL_IP6_FLAGS])
-		tun_info->key.tun_flags = nla_get_u16(tb[LWTUNNEL_IP6_FLAGS]);
+		tun_info->key.tun_flags = nla_get_be16(tb[LWTUNNEL_IP6_FLAGS]);
 
 	tun_info->mode = IP_TUNNEL_INFO_TX | IP_TUNNEL_INFO_IPV6;
 	tun_info->options_len = 0;
@@ -376,12 +376,12 @@ static int ip6_tun_fill_encap_info(struct sk_buff *skb,
 {
 	struct ip_tunnel_info *tun_info = lwt_tun_info(lwtstate);
 
-	if (nla_put_u64(skb, LWTUNNEL_IP6_ID, tun_info->key.tun_id) ||
+	if (nla_put_be64(skb, LWTUNNEL_IP6_ID, tun_info->key.tun_id) ||
 	    nla_put_in6_addr(skb, LWTUNNEL_IP6_DST, &tun_info->key.u.ipv6.dst) ||
 	    nla_put_in6_addr(skb, LWTUNNEL_IP6_SRC, &tun_info->key.u.ipv6.src) ||
 	    nla_put_u8(skb, LWTUNNEL_IP6_HOPLIMIT, tun_info->key.tos) ||
 	    nla_put_u8(skb, LWTUNNEL_IP6_TC, tun_info->key.ttl) ||
-	    nla_put_u16(skb, LWTUNNEL_IP6_FLAGS, tun_info->key.tun_flags))
+	    nla_put_be16(skb, LWTUNNEL_IP6_FLAGS, tun_info->key.tun_flags))
 		return -ENOMEM;
 
 	return 0;
-- 
2.5.0
