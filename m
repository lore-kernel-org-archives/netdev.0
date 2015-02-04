From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sit: fix some __be16/u16 mismatches
Date: Wed, 04 Feb 2015 15:12:04 -0800
Message-ID: <1423091524.31870.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37652 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475AbbBDXMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 18:12:06 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so22193242igd.4
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 15:12:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fixes following sparse warnings :

net/ipv6/sit.c:1509:32: warning: incorrect type in assignment (different base types)
net/ipv6/sit.c:1509:32:    expected restricted __be16 [usertype] sport
net/ipv6/sit.c:1509:32:    got unsigned short
net/ipv6/sit.c:1514:32: warning: incorrect type in assignment (different base types)
net/ipv6/sit.c:1514:32:    expected restricted __be16 [usertype] dport
net/ipv6/sit.c:1514:32:    got unsigned short
net/ipv6/sit.c:1711:38: warning: incorrect type in argument 3 (different base types)
net/ipv6/sit.c:1711:38:    expected unsigned short [unsigned] [usertype] value
net/ipv6/sit.c:1711:38:    got restricted __be16 [usertype] sport
net/ipv6/sit.c:1713:38: warning: incorrect type in argument 3 (different base types)
net/ipv6/sit.c:1713:38:    expected unsigned short [unsigned] [usertype] value
net/ipv6/sit.c:1713:38:    got restricted __be16 [usertype] dport

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/sit.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 213546bd6d5d..cdbfe5af6187 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1506,12 +1506,12 @@ static bool ipip6_netlink_encap_parms(struct nlattr *data[],
 
 	if (data[IFLA_IPTUN_ENCAP_SPORT]) {
 		ret = true;
-		ipencap->sport = nla_get_u16(data[IFLA_IPTUN_ENCAP_SPORT]);
+		ipencap->sport = nla_get_be16(data[IFLA_IPTUN_ENCAP_SPORT]);
 	}
 
 	if (data[IFLA_IPTUN_ENCAP_DPORT]) {
 		ret = true;
-		ipencap->dport = nla_get_u16(data[IFLA_IPTUN_ENCAP_DPORT]);
+		ipencap->dport = nla_get_be16(data[IFLA_IPTUN_ENCAP_DPORT]);
 	}
 
 	return ret;
@@ -1707,9 +1707,9 @@ static int ipip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 
 	if (nla_put_u16(skb, IFLA_IPTUN_ENCAP_TYPE,
 			tunnel->encap.type) ||
-	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_SPORT,
+	    nla_put_be16(skb, IFLA_IPTUN_ENCAP_SPORT,
 			tunnel->encap.sport) ||
-	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_DPORT,
+	    nla_put_be16(skb, IFLA_IPTUN_ENCAP_DPORT,
 			tunnel->encap.dport) ||
 	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_FLAGS,
 			tunnel->encap.flags))
