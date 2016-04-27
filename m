From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 15/17] ipv6: rename IP6_UPD_PO_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:41 -0700
Message-ID: <1461800683-25034-16-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33147 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189AbcD0Xp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:27 -0400
Received: by mail-pa0-f48.google.com with SMTP id zm5so27876596pac.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:27 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename IP6_UPD_PO_STATS_BH() to __IP6_UPD_PO_STATS()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ipv6.h   | 2 +-
 net/ipv6/ip6_input.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index aba8760dd108..9f3b53f2819b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -175,7 +175,7 @@ extern int sysctl_mld_qrv;
 		_DEVADD(net, ipv6, 64_BH, idev, field, val)
 #define IP6_UPD_PO_STATS(net, idev,field,val)   \
 		_DEVUPD(net, ipv6, 64, idev, field, val)
-#define IP6_UPD_PO_STATS_BH(net, idev,field,val)   \
+#define __IP6_UPD_PO_STATS(net, idev,field,val)   \
 		_DEVUPD(net, ipv6, 64_BH, idev, field, val)
 #define ICMP6_INC_STATS(net, idev, field)	\
 		_DEVINCATOMIC(net, icmpv6, , idev, field)
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 218bb906c620..6ed56012005d 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -78,7 +78,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 
 	idev = __in6_dev_get(skb->dev);
 
-	IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_IN, skb->len);
+	__IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_IN, skb->len);
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL ||
 	    !idev || unlikely(idev->cnf.disable_ipv6)) {
@@ -297,7 +297,7 @@ int ip6_mc_input(struct sk_buff *skb)
 	const struct ipv6hdr *hdr;
 	bool deliver;
 
-	IP6_UPD_PO_STATS_BH(dev_net(skb_dst(skb)->dev),
+	__IP6_UPD_PO_STATS(dev_net(skb_dst(skb)->dev),
 			 ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_INMCAST,
 			 skb->len);
 
-- 
2.8.0.rc3.226.g39d4020
