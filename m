From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 47/53] ipvs: remove unused function ip_vs_set_state_timeout
Date: Mon,  1 May 2017 12:47:14 +0200
Message-ID: <1493635640-24325-48-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49670 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S379022AbdEAKtH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:49:07 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 42655210586
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:07 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3280DFF2D0
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:07 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 17839FF2CF
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:05 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>

There are no in-tree callers of this function and it isn't exported.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h              |  2 --
 net/netfilter/ipvs/ip_vs_proto.c | 22 ----------------------
 2 files changed, 24 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 632082300e77..4f4f786255ef 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1349,8 +1349,6 @@ int ip_vs_protocol_init(void);
 void ip_vs_protocol_cleanup(void);
 void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags);
 int *ip_vs_create_timeout_table(int *table, int size);
-int ip_vs_set_state_timeout(int *table, int num, const char *const *names,
-			    const char *name, int to);
 void ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
 			       const struct sk_buff *skb, int offset,
 			       const char *msg);
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 8ae480715cea..ca880a3ad033 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -193,28 +193,6 @@ ip_vs_create_timeout_table(int *table, int size)
 }
 
 
-/*
- *	Set timeout value for state specified by name
- */
-int
-ip_vs_set_state_timeout(int *table, int num, const char *const *names,
-			const char *name, int to)
-{
-	int i;
-
-	if (!table || !name || !to)
-		return -EINVAL;
-
-	for (i = 0; i < num; i++) {
-		if (strcmp(names[i], name))
-			continue;
-		table[i] = to * HZ;
-		return 0;
-	}
-	return -ENOENT;
-}
-
-
 const char * ip_vs_state_name(__u16 proto, int state)
 {
 	struct ip_vs_protocol *pp = ip_vs_proto_get(proto);
-- 
2.1.4
