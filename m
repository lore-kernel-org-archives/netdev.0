From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 53/53] netfilter: nf_log: get rid of XT_LOG_* macros
Date: Mon, 26 Sep 2016 01:07:03 +0200
Message-ID: <1474844823-2026-54-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54850 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034933AbcIYXIO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:08:14 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id A433EE3A1E
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:12 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 93F9FDA818
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:12 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4957EDA819
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:10 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

nf_log is used by both nftables and iptables, so use XT_LOG_XXX macros
here is not appropriate. Replace them with NF_LOG_XXX.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_log_ipv4.c |  6 +++---
 net/ipv6/netfilter/nf_log_ipv6.c | 14 +++++++-------
 net/netfilter/nf_log_common.c    |  4 ++--
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/netfilter/nf_log_ipv4.c b/net/ipv4/netfilter/nf_log_ipv4.c
index 5b571e1b5f15..856648966f4c 100644
--- a/net/ipv4/netfilter/nf_log_ipv4.c
+++ b/net/ipv4/netfilter/nf_log_ipv4.c
@@ -76,7 +76,7 @@ static void dump_ipv4_packet(struct nf_log_buf *m,
 	if (ntohs(ih->frag_off) & IP_OFFSET)
 		nf_log_buf_add(m, "FRAG:%u ", ntohs(ih->frag_off) & IP_OFFSET);
 
-	if ((logflags & XT_LOG_IPOPT) &&
+	if ((logflags & NF_LOG_IPOPT) &&
 	    ih->ihl * 4 > sizeof(struct iphdr)) {
 		const unsigned char *op;
 		unsigned char _opt[4 * 15 - sizeof(struct iphdr)];
@@ -250,7 +250,7 @@ static void dump_ipv4_packet(struct nf_log_buf *m,
 	}
 
 	/* Max length: 15 "UID=4294967295 " */
-	if ((logflags & XT_LOG_UID) && !iphoff)
+	if ((logflags & NF_LOG_UID) && !iphoff)
 		nf_log_dump_sk_uid_gid(m, skb->sk);
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */
@@ -282,7 +282,7 @@ static void dump_ipv4_mac_header(struct nf_log_buf *m,
 	if (info->type == NF_LOG_TYPE_LOG)
 		logflags = info->u.log.logflags;
 
-	if (!(logflags & XT_LOG_MACDECODE))
+	if (!(logflags & NF_LOG_MACDECODE))
 		goto fallback;
 
 	switch (dev->type) {
diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index f6aee2895fee..57d86066a13b 100644
--- a/net/ipv6/netfilter/nf_log_ipv6.c
+++ b/net/ipv6/netfilter/nf_log_ipv6.c
@@ -84,7 +84,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 		}
 
 		/* Max length: 48 "OPT (...) " */
-		if (logflags & XT_LOG_IPOPT)
+		if (logflags & NF_LOG_IPOPT)
 			nf_log_buf_add(m, "OPT ( ");
 
 		switch (currenthdr) {
@@ -121,7 +121,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 		case IPPROTO_ROUTING:
 		case IPPROTO_HOPOPTS:
 			if (fragment) {
-				if (logflags & XT_LOG_IPOPT)
+				if (logflags & NF_LOG_IPOPT)
 					nf_log_buf_add(m, ")");
 				return;
 			}
@@ -129,7 +129,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 			break;
 		/* Max Length */
 		case IPPROTO_AH:
-			if (logflags & XT_LOG_IPOPT) {
+			if (logflags & NF_LOG_IPOPT) {
 				struct ip_auth_hdr _ahdr;
 				const struct ip_auth_hdr *ah;
 
@@ -161,7 +161,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 			hdrlen = (hp->hdrlen+2)<<2;
 			break;
 		case IPPROTO_ESP:
-			if (logflags & XT_LOG_IPOPT) {
+			if (logflags & NF_LOG_IPOPT) {
 				struct ip_esp_hdr _esph;
 				const struct ip_esp_hdr *eh;
 
@@ -194,7 +194,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 			nf_log_buf_add(m, "Unknown Ext Hdr %u", currenthdr);
 			return;
 		}
-		if (logflags & XT_LOG_IPOPT)
+		if (logflags & NF_LOG_IPOPT)
 			nf_log_buf_add(m, ") ");
 
 		currenthdr = hp->nexthdr;
@@ -277,7 +277,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 	}
 
 	/* Max length: 15 "UID=4294967295 " */
-	if ((logflags & XT_LOG_UID) && recurse)
+	if ((logflags & NF_LOG_UID) && recurse)
 		nf_log_dump_sk_uid_gid(m, skb->sk);
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */
@@ -295,7 +295,7 @@ static void dump_ipv6_mac_header(struct nf_log_buf *m,
 	if (info->type == NF_LOG_TYPE_LOG)
 		logflags = info->u.log.logflags;
 
-	if (!(logflags & XT_LOG_MACDECODE))
+	if (!(logflags & NF_LOG_MACDECODE))
 		goto fallback;
 
 	switch (dev->type) {
diff --git a/net/netfilter/nf_log_common.c b/net/netfilter/nf_log_common.c
index a5aa5967b8e1..119fe1cb1ea9 100644
--- a/net/netfilter/nf_log_common.c
+++ b/net/netfilter/nf_log_common.c
@@ -77,7 +77,7 @@ int nf_log_dump_tcp_header(struct nf_log_buf *m, const struct sk_buff *skb,
 	nf_log_buf_add(m, "SPT=%u DPT=%u ",
 		       ntohs(th->source), ntohs(th->dest));
 	/* Max length: 30 "SEQ=4294967295 ACK=4294967295 " */
-	if (logflags & XT_LOG_TCPSEQ) {
+	if (logflags & NF_LOG_TCPSEQ) {
 		nf_log_buf_add(m, "SEQ=%u ACK=%u ",
 			       ntohl(th->seq), ntohl(th->ack_seq));
 	}
@@ -107,7 +107,7 @@ int nf_log_dump_tcp_header(struct nf_log_buf *m, const struct sk_buff *skb,
 	/* Max length: 11 "URGP=65535 " */
 	nf_log_buf_add(m, "URGP=%u ", ntohs(th->urg_ptr));
 
-	if ((logflags & XT_LOG_TCPOPT) && th->doff*4 > sizeof(struct tcphdr)) {
+	if ((logflags & NF_LOG_TCPOPT) && th->doff*4 > sizeof(struct tcphdr)) {
 		u_int8_t _opt[60 - sizeof(struct tcphdr)];
 		const u_int8_t *op;
 		unsigned int i;
-- 
2.1.4
