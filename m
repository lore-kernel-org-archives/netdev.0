From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next] fou: Fix typo in returning flags in netlink
Date: Wed,  5 Nov 2014 16:49:38 -0800
Message-ID: <1415234978-31931-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:47235 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbaKFAtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 19:49:51 -0500
Received: by mail-ig0-f169.google.com with SMTP id hn18so9344797igb.4
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 16:49:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When filling netlink info, dport is being returned as flags. Fix
instances to return correct value.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ip_gre.c | 2 +-
 net/ipv4/ipip.c   | 2 +-
 net/ipv6/sit.c    | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 12055fd..ac84912 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -789,7 +789,7 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u16(skb, IFLA_GRE_ENCAP_DPORT,
 			t->encap.dport) ||
 	    nla_put_u16(skb, IFLA_GRE_ENCAP_FLAGS,
-			t->encap.dport))
+			t->encap.flags))
 		goto nla_put_failure;
 
 	return 0;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 37096d6..40403114 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -465,7 +465,7 @@ static int ipip_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_DPORT,
 			tunnel->encap.dport) ||
 	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_FLAGS,
-			tunnel->encap.dport))
+			tunnel->encap.flags))
 		goto nla_put_failure;
 
 	return 0;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 58e5b47..45ad924 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1714,7 +1714,7 @@ static int ipip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_DPORT,
 			tunnel->encap.dport) ||
 	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_FLAGS,
-			tunnel->encap.dport))
+			tunnel->encap.flags))
 		goto nla_put_failure;
 
 	return 0;
-- 
2.1.0.rc2.206.gedb03e5
