From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: fix compile error in skb_orphan_partial()
Date: Tue, 16 May 2017 13:27:53 -0700
Message-ID: <1494966473.6465.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170516112125.517607f8@canb.auug.org.au>
         <f63533e7-edd3-4c0d-ddff-e3409d15abc6@infradead.org>
         <CAP=VYLoYkz1HE4yOHVGQvBanDtpkWhtHBMvbeuyd8PtNFCivRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Randy Dunlap <rdunlap@infradead.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35992 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752157AbdEPU16 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 16:27:58 -0400
Received: by mail-pg0-f67.google.com with SMTP id h64so17851843pge.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 13:27:58 -0700 (PDT)
In-Reply-To: <CAP=VYLoYkz1HE4yOHVGQvBanDtpkWhtHBMvbeuyd8PtNFCivRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If CONFIG_INET is not set, net/core/sock.c can not compile :

net/core/sock.c: In function ‘skb_orphan_partial’:
net/core/sock.c:1810:2: error: implicit declaration of function
‘skb_is_tcp_pure_ack’ [-Werror=implicit-function-declaration]
  if (skb_is_tcp_pure_ack(skb))
  ^

Fix this by always including <net/tcp.h>

Fixes: f6ba8d33cfbb ("netem: fix skb_orphan_partial()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Reported-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/core/sock.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index e43e71d7856b385111cd4c4b1bd835a78c670c60..727f924b7f91f495d9e7a4e7297c9c937d3258ed 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -139,10 +139,7 @@
 
 #include <trace/events/sock.h>
 
-#ifdef CONFIG_INET
 #include <net/tcp.h>
-#endif
-
 #include <net/busy_poll.h>
 
 static DEFINE_MUTEX(proto_list_mutex);
