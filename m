From: Xiang Gao <qasdfgtyuiop@gmail.com>
Subject: [PATCH 1/1] ipv6_skip_exthdr: use ipv6_authlen for AH header length computation
Date: Fri, 15 Sep 2017 01:04:27 -0400
Message-ID: <CAMtaSwRk0ne+kG3ejH6685N=ByEAVOkvtyCbmPu9jTng3h2YNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: trivial@kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:37763 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdIOFEs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 01:04:48 -0400
Received: by mail-qt0-f194.google.com with SMTP id u48so855416qtc.4
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 22:04:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 09cf2e3cf09cf591283785aaa8159baf39ac2e08 Mon Sep 17 00:00:00 2001
From: Xiang Gao <qasdfgtyuiop@gmail.com>
Date: Fri, 15 Sep 2017 00:44:12 -0400
Subject: [PATCH] ipv6_skip_exthdr: use ipv6_authlen for AH hdrlen

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
@@ -99,7 +99,7 @@ int ipv6_skip_exthdr(const struct sk_buff *skb, int
start, u8 *nexthdrp,
  break;
  hdrlen = 8;
  } else if (nexthdr == NEXTHDR_AUTH)
- hdrlen = (hp->hdrlen+2)<<2;
+ hdrlen = ipv6_authlen(hp);
  else
  hdrlen = ipv6_optlen(hp);

-- 
2.14.1


Signed-off-by: Xiang Gao <qasdfgtyuiop@gmail.com>
