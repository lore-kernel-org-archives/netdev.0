From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/9] netfilter: ctnetlink: reject new conntrack request with different l4proto
Date: Wed, 10 Aug 2016 21:16:44 +0200
Message-ID: <1470856605-7903-9-git-send-email-pablo@netfilter.org>
References: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58046 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S941230AbcHJTRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 15:17:00 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 546281F18D3
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 21:16:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 45FC6100A60
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 21:16:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 4A9C8100A59
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 21:16:56 +0200 (CEST)
In-Reply-To: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Currently, user can add a conntrack with different l4proto via nfnetlink.
For example, original tuple is TCP while reply tuple is SCTP. This is
invalid combination, we should report EINVAL to userspace.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index b9bfe64..fdfc71f 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1894,6 +1894,8 @@ static int ctnetlink_new_conntrack(struct net *net, struct sock *ctnl,
 
 			if (!cda[CTA_TUPLE_ORIG] || !cda[CTA_TUPLE_REPLY])
 				return -EINVAL;
+			if (otuple.dst.protonum != rtuple.dst.protonum)
+				return -EINVAL;
 
 			ct = ctnetlink_create_conntrack(net, &zone, cda, &otuple,
 							&rtuple, u3);
-- 
2.1.4
