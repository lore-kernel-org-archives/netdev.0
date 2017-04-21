From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH iproute2] gre6: fix copy/paste bugs in GREv6 attribute manipulation
Date: Fri, 21 Apr 2017 14:14:25 -0400
Message-ID: <20170421181425.166260-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33938 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423660AbdDUSXu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:23:50 -0400
Received: by mail-qk0-f172.google.com with SMTP id y63so48182581qkd.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:23:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

Fixes: af89576d7a8c("iproute2: GRE over IPv6 tunnel support.")
Signed-off-by: Craig Gallek <kraig@google.com>
---
 ip/link_gre6.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index a91f635760fa..1b4fb051b37f 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -355,7 +355,7 @@ get_failed:
 	addattr_l(n, 1024, IFLA_GRE_TTL, &hop_limit, 1);
 	addattr_l(n, 1024, IFLA_GRE_ENCAP_LIMIT, &encap_limit, 1);
 	addattr_l(n, 1024, IFLA_GRE_FLOWINFO, &flowinfo, 4);
-	addattr_l(n, 1024, IFLA_GRE_FLAGS, &flowinfo, 4);
+	addattr32(n, 1024, IFLA_GRE_FLAGS, flags);
 
 	addattr16(n, 1024, IFLA_GRE_ENCAP_TYPE, encaptype);
 	addattr16(n, 1024, IFLA_GRE_ENCAP_FLAGS, encapflags);
@@ -383,7 +383,7 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		flags = rta_getattr_u32(tb[IFLA_GRE_FLAGS]);
 
 	if (tb[IFLA_GRE_FLOWINFO])
-		flags = rta_getattr_u32(tb[IFLA_GRE_FLOWINFO]);
+		flowinfo = rta_getattr_u32(tb[IFLA_GRE_FLOWINFO]);
 
 	if (tb[IFLA_GRE_REMOTE]) {
 		struct in6_addr addr;
-- 
2.12.2.816.g2cccc81164-goog
