From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] ipv6: use ipv6_addr_any() helper
Date: Wed, 22 May 2013 23:41:06 +0800
Message-ID: <1369237266-21742-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:56885 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756505Ab3EVPle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 11:41:34 -0400
Received: by mail-pa0-f41.google.com with SMTP id rl6so1935432pac.28
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 08:41:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

ipv6_addr_any() is a faster way to determine if an addr
is ipv6 any addr, no need to compute the addr type.

Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d684d23..e052696 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3846,7 +3846,7 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 		valid = INFINITY_LIFE_TIME;
 	}
 
-	if (ipv6_addr_type(&ifa->peer_addr) != IPV6_ADDR_ANY) {
+	if (!ipv6_addr_any(&ifa->peer_addr)) {
 		if (nla_put(skb, IFA_LOCAL, 16, &ifa->addr) < 0 ||
 		    nla_put(skb, IFA_ADDRESS, 16, &ifa->peer_addr) < 0)
 			goto error;
@@ -4579,7 +4579,7 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 			ip6_ins_rt(ifp->rt);
 		if (ifp->idev->cnf.forwarding)
 			addrconf_join_anycast(ifp);
-		if (ipv6_addr_type(&ifp->peer_addr) != IPV6_ADDR_ANY)
+		if (!ipv6_addr_any(&ifp->peer_addr))
 			addrconf_prefix_route(&ifp->peer_addr, 128,
 					      ifp->idev->dev, 0, 0);
 		break;
@@ -4587,7 +4587,7 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 		if (ifp->idev->cnf.forwarding)
 			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
-		if (ipv6_addr_type(&ifp->peer_addr) != IPV6_ADDR_ANY) {
+		if (!ipv6_addr_any(&ifp->peer_addr)) {
 			struct rt6_info *rt;
 			struct net_device *dev = ifp->idev->dev;
 
