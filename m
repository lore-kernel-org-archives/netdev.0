From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 15/30] ipv4: Only compute net once in ipmr_forward_finish
Date: Tue, 15 Sep 2015 20:04:03 -0500
Message-ID: <1442365458-16349-15-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39422 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbbIPBNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:13:45 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/ipmr.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 075bc695ae34..dfe4e8ec6c3a 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1681,9 +1681,10 @@ static void ip_encap(struct net *net, struct sk_buff *skb,
 static inline int ipmr_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct ip_options *opt = &(IPCB(skb)->opt);
+	struct net *net = dev_net(skb_dst(skb)->dev);
 
-	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
-	IP_ADD_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTOCTETS, skb->len);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP_ADD_STATS_BH(net, IPSTATS_MIB_OUTOCTETS, skb->len);
 
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
-- 
2.2.1
