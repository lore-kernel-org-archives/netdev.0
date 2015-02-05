From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 2/2] ipv6: Make __ipv6_select_ident static
Date: Thu,  5 Feb 2015 09:41:37 -0500
Message-ID: <1423147297-4757-3-git-send-email-vyasevic@redhat.com>
References: <1423147297-4757-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:34268 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbbBEOlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 09:41:46 -0500
Received: by mail-qg0-f46.google.com with SMTP id j5so6368219qga.5
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 06:41:45 -0800 (PST)
In-Reply-To: <1423147297-4757-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make __ipv6_select_ident() static as it isn't used outside
the file.

Fixes: 0508c07f5e0c9 (ipv6: Select fragment id during UFO segmentation if not set.)
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/net/ipv6.h     | 2 --
 net/ipv6/output_core.c | 3 ++-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 6e416f6..fde3b59 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -671,8 +671,6 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
 
-u32 __ipv6_select_ident(u32 hashrnd, struct in6_addr *dst,
-			struct in6_addr *src);
 void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
 void ipv6_proxy_select_ident(struct sk_buff *skb);
 
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index a86cf60..74581f7 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -9,7 +9,8 @@
 #include <net/addrconf.h>
 #include <net/secure_seq.h>
 
-u32 __ipv6_select_ident(u32 hashrnd, struct in6_addr *dst, struct in6_addr *src)
+static u32 __ipv6_select_ident(u32 hashrnd, struct in6_addr *dst,
+			       struct in6_addr *src)
 {
 	u32 hash, id;
 
-- 
1.9.3
