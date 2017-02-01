From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv6: add NLM_F_APPEND in notifications when applicable
Date: Tue, 31 Jan 2017 16:51:37 -0800
Message-ID: <1485910297-14092-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35461 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdBAAxO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 19:53:14 -0500
Received: by mail-pf0-f179.google.com with SMTP id f144so113815847pfa.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 16:51:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 does not set the NLM_F_APPEND flag in notifications to signal that
a NEWROUTE is an append versus a new route or a replaced one. Add the
flag if the request has it.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
sending this one outside of the multipath patch set since it has
nothing to do with multipath.

 net/ipv6/ip6_fib.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index ef5485204522..bcaf247232d7 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -746,6 +746,9 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 	u16 nlflags = NLM_F_EXCL;
 	int err;
 
+	if (info->nlh && (info->nlh->nlmsg_flags & NLM_F_APPEND))
+		nlflags |= NLM_F_APPEND;
+
 	ins = &fn->leaf;
 
 	for (iter = fn->leaf; iter; iter = iter->dst.rt6_next) {
-- 
2.1.4
