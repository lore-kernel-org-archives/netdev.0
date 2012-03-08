From: pablo@netfilter.org
Subject: [PATCH 14/23] netfilter: xt_LOG: fix bogus extra layer-4 logging information
Date: Thu,  8 Mar 2012 02:01:03 +0100
Message-ID: <1331168472-5820-15-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56124 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751759Ab2CHBBg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2012 20:01:36 -0500
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Weinberger <richard@nod.at>

In 16059b5 netfilter: merge ipt_LOG and ip6_LOG into xt_LOG, we have
merged ipt_LOG and ip6t_LOG.

However:

IN=wlan0 OUT= MAC=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
SRC=213.150.61.61 DST=192.168.1.133 LEN=40 TOS=0x00 PREC=0x00 TTL=117
ID=10539 DF PROTO=TCP SPT=80 DPT=49013 WINDOW=0 RES=0x00 ACK RST
URGP=0 PROTO=UDPLITE SPT=80 DPT=49013 LEN=45843 PROTO=ICMP TYPE=0
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Several missing break in the code led to including bogus layer-4
information. This patch fixes this problem.

Signed-off-by: Richard Weinberger <richard@nod.at>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_LOG.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index 1595608..f99f8de 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -216,12 +216,14 @@ static void dump_ipv4_packet(struct sbuff *m,
 				    ntohs(ih->frag_off) & IP_OFFSET,
 				    iphoff+ih->ihl*4, logflags))
 			return;
+		break;
 	case IPPROTO_UDP:
 	case IPPROTO_UDPLITE:
 		if (dump_udp_header(m, skb, ih->protocol,
 				    ntohs(ih->frag_off) & IP_OFFSET,
 				    iphoff+ih->ihl*4))
 			return;
+		break;
 	case IPPROTO_ICMP: {
 		struct icmphdr _icmph;
 		const struct icmphdr *ich;
@@ -649,10 +651,12 @@ static void dump_ipv6_packet(struct sbuff *m,
 		if (dump_tcp_header(m, skb, currenthdr, fragment, ptr,
 		    logflags))
 			return;
+		break;
 	case IPPROTO_UDP:
 	case IPPROTO_UDPLITE:
 		if (dump_udp_header(m, skb, currenthdr, fragment, ptr))
 			return;
+		break;
 	case IPPROTO_ICMPV6: {
 		struct icmp6hdr _icmp6h;
 		const struct icmp6hdr *ic;
-- 
1.7.7.3
