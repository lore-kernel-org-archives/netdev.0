From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 6/6] dccp: Add check for truncated ICMPv6 DCCP error packets
Date: Fri, 25 Jul 2008 10:02:58 +0100
Message-ID: <1216976578-17767-7-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_icmp_payload_bug_fixes>
 <1216976578-17767-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1216976578-17767-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1216976578-17767-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1216976578-17767-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1216976578-17767-5-git-send-email-gerrit@erg.abdn.ac.uk>
 <1216976578-17767-6-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:52416 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753499AbYGYJDX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 05:03:23 -0400
In-Reply-To: <1216976578-17767-6-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

This patch adds a minimum-length check for ICMPv6 packets, to allow meaningful
DCCP sequence number checks, as per the previous patch for ICMPv4 payloads.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv6.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -96,6 +96,11 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	__u64 seq;
 	struct net *net = dev_net(skb->dev);
 
+	if (skb->len < offset + __dccp_basic_hdr_len(dh)) {
+		ICMP6_INC_STATS_BH(__in6_dev_get(skb->dev), ICMP6_MIB_INERRORS);
+		return;
+	}
+
 	sk = inet6_lookup(net, &dccp_hashinfo,
 			&hdr->daddr, dh->dccph_dport,
 			&hdr->saddr, dh->dccph_sport, inet6_iif(skb));
