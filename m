From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: v2 [PATCH 7/7] dccp: Add check for truncated ICMPv6 DCCP error
	packets
Date: Fri, 25 Jul 2008 15:31:07 +0100
Message-ID: <20080725143107.GD7422@gerrit.erg.abdn.ac.uk>
References: <1216976578-17767-1-git-send-email-gerrit@erg.abdn.ac.uk> <20080725142834.GA7422@gerrit.erg.abdn.ac.uk> <20080725142957.GB7422@gerrit.erg.abdn.ac.uk> <20080725143033.GC7422@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:40460 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751307AbYGYObN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 10:31:13 -0400
Content-Disposition: inline
In-Reply-To: <20080725143033.GC7422@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a minimum-length check for ICMPv6 packets, to allow meaningful
DCCP sequence number checks, as per the previous patch for ICMPv4 payloads.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv6.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -96,6 +96,11 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	__u64 seq;
 	struct net *net = dev_net(skb->dev);
 
+	if (dccp_skb_too_short(skb, offset)) {
+		ICMP6_INC_STATS_BH(__in6_dev_get(skb->dev), ICMP6_MIB_INERRORS);
+		return;
+	}
+
 	sk = inet6_lookup(net, &dccp_hashinfo,
 			&hdr->daddr, dh->dccph_dport,
 			&hdr->saddr, dh->dccph_sport, inet6_iif(skb));
