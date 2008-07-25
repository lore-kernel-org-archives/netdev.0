From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 5/6] dccp: Fix incorrect length check for ICMPv4 packets
Date: Fri, 25 Jul 2008 10:02:57 +0100
Message-ID: <1216976578-17767-6-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_icmp_payload_bug_fixes>
 <1216976578-17767-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1216976578-17767-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1216976578-17767-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1216976578-17767-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1216976578-17767-5-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:52428 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754049AbYGYJDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 05:03:31 -0400
In-Reply-To: <1216976578-17767-5-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

Unlike TCP, which only needs 8 octets of original packet data, DCCP requires
minimally 12 bytes for ICMP-payload sequence number checks.

This patch replaces the insufficient length constant of 8 with a dynamic
value of __dccp_basic_hdr_len(). This is safer, since it takes into account
the switch between 24bit/48bit sequence numbers (`X' bit in RFC 4340, 5.1).

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -207,7 +207,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	int err;
 	struct net *net = dev_net(skb->dev);
 
-	if (skb->len < (iph->ihl << 2) + 8) {
+	if (skb->len < (iph->ihl << 2) + __dccp_basic_hdr_len(dh)) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
 	}
