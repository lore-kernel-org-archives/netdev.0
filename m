From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: Initialize flow flags in input path
Date: Tue, 29 Sep 2015 19:07:07 -0700
Message-ID: <1443578827-40533-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32997 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbbI3CHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 22:07:14 -0400
Received: by pacex6 with SMTP id ex6so23458181pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 19:07:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fib_table_lookup tracepoint found 2 places where the flowi4_flags is
not initialized.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/fib_frontend.c | 1 +
 net/ipv4/route.c        | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 6fcbd215cdbc..690bcbc59f26 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -340,6 +340,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
 	fl4.flowi4_tun_key.tun_id = 0;
+	fl4.flowi4_flags = 0;
 
 	no_addr = idev->ifa_list == NULL;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8c84a6664b30..13ac8d012aa7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1743,6 +1743,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_flags = 0;
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
 	err = fib_lookup(net, &fl4, &res, 0);
-- 
1.9.1
