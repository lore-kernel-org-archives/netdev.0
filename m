From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 11/22] icmp: Don't leak original dst into ip_route_input()
Date: Tue, 21 Jul 2015 10:43:55 +0200
Message-ID: <1cc86daa21ef9d79683dd175c02c4440e827597e.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	ast@plumgrid.com, weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40039 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754053AbbGUIoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 04:44:24 -0400
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_route_input() unconditionally overwrites the dst. Hide the original
dst attached to the skb by calling skb_dst_set(skb, NULL) prior to
ip_route_input().

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/icmp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f5203fb..c0556f1 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -496,6 +496,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 		}
 		/* Ugh! */
 		orefdst = skb_in->_skb_refdst; /* save old refdst */
+		skb_dst_set(skb_in, NULL);
 		err = ip_route_input(skb_in, fl4_dec.daddr, fl4_dec.saddr,
 				     RT_TOS(tos), rt2->dst.dev);
 
-- 
2.4.3
