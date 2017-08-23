From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] net/sock: allow the user to set negative peek offset
Date: Wed, 23 Aug 2017 11:57:51 +0200
Message-ID: <64e676e59d203f13cd326c3b0cf6b05287b69e1b.1503481941.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Matthew Dawson <matthew@mjdsystems.ca>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Sam Kumar <samanthakumar@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50630 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753728AbdHWJ7x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 05:59:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is necessary to allow the user to disable peeking with
offset once it's enabled.
Unix sockets already allow the above, with this patch we
permit it for udp[6] sockets, too.

Fixes: 627d2d6b5500 ("udp: enable MSG_PEEK at non-zero offset")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/core/sock.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index ac2a404c73eb..679367ce1432 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2408,9 +2408,6 @@ EXPORT_SYMBOL(__sk_mem_reclaim);
 
 int sk_set_peek_off(struct sock *sk, int val)
 {
-	if (val < 0)
-		return -EINVAL;
-
 	sk->sk_peek_off = val;
 	return 0;
 }
-- 
2.13.5
