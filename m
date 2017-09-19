From: Xiang Gao <qasdfgtyuiop@gmail.com>
Subject: [PATCH] ipv6_skip_exthdr: use ipv6_authlen for AH hdrlen
Date: Tue, 19 Sep 2017 08:59:50 -0400
Message-ID: <20170919125950.11537-1-qasdfgtyuiop@gmail.com>
Cc: qasdfgtyuiop@gmail.com
To: trivial@kernel.org, netdev@vger.kernel.org, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:37757 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdISNAL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 09:00:11 -0400
Received: by mail-ua0-f196.google.com with SMTP id q29so1148281uaf.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 06:00:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipv6_skip_exthdr, the lengh of AH header is computed manually
as (hp->hdrlen+2)<<2. However, in include/linux/ipv6.h, a macro
named ipv6_authlen is already defined for exactly the same job. This
commit replaces the manual computation code with the macro.
---
 net/ipv6/exthdrs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 305e2ed730bf..115d60919f72 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -99,7 +99,7 @@ int ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp,
 				break;
 			hdrlen = 8;
 		} else if (nexthdr == NEXTHDR_AUTH)
-			hdrlen = (hp->hdrlen+2)<<2;
+			hdrlen = ipv6_authlen(hp);
 		else
 			hdrlen = ipv6_optlen(hp);
 
-- 
2.14.1
