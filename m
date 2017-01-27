From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3 1/4] net: ipv6: add NLM_F_APPEND in notifications when applicable
Date: Fri, 27 Jan 2017 15:20:55 -0800
Message-ID: <1485559258-4856-2-git-send-email-dsa@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36743 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750741AbdA0XWD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 18:22:03 -0500
Received: by mail-pg0-f51.google.com with SMTP id 3so26077477pgj.3
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 15:21:05 -0800 (PST)
In-Reply-To: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 does not set the NLM_F_APPEND flag in notifications to signal that
a NEWROUTE is an append versus a new route or a replaced one. Add the
flag if the request has it.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/ip6_fib.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index ef5485204522..bcaf247232d7 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -746,6 +746,9 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 	u16 nlflags = NLM_F_EXCL;
 	int err;
 
+	if (info->nlh && info->nlh->nlmsg_flags & NLM_F_APPEND)
+		nlflags |= NLM_F_APPEND;
+
 	ins = &fn->leaf;
 
 	for (iter = fn->leaf; iter; iter = iter->dst.rt6_next) {
-- 
2.1.4
