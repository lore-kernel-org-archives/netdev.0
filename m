From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/2] netfilter: ebt_nflog: fix unexpected truncated packet
Date: Thu,  6 Jul 2017 14:54:25 +0200
Message-ID: <1499345665-7428-3-git-send-email-pablo@netfilter.org>
References: <1499345665-7428-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38602 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752540AbdGFMyh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 08:54:37 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 8BE834D660
        for <netdev@vger.kernel.org>; Thu,  6 Jul 2017 14:54:25 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7E0C3DA812
        for <netdev@vger.kernel.org>; Thu,  6 Jul 2017 14:54:25 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5AAB5D1CB1
        for <netdev@vger.kernel.org>; Thu,  6 Jul 2017 14:54:21 +0200 (CEST)
In-Reply-To: <1499345665-7428-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

"struct nf_loginfo li;" is a local variable, so we should set the flags
to 0 explicitly, else, packets maybe truncated unexpectedly when copied
to the userspace.

Fixes: 7643507fe8b5 ("netfilter: xt_NFLOG: nflog-range does not truncate packets")
Cc: Vishwanath Pai <vpai@akamai.com>
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_nflog.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/netfilter/ebt_nflog.c b/net/bridge/netfilter/ebt_nflog.c
index c1dc48686200..da1c2fdc08c8 100644
--- a/net/bridge/netfilter/ebt_nflog.c
+++ b/net/bridge/netfilter/ebt_nflog.c
@@ -30,6 +30,7 @@ ebt_nflog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	li.u.ulog.copy_len = info->len;
 	li.u.ulog.group = info->group;
 	li.u.ulog.qthreshold = info->threshold;
+	li.u.ulog.flags = 0;
 
 	nf_log_packet(net, PF_BRIDGE, xt_hooknum(par), skb, xt_in(par),
 		      xt_out(par), &li, "%s", info->prefix);
-- 
2.1.4
