From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: clear sk_err_soft in sk_clone_lock()
Date: Fri, 28 Oct 2016 13:40:24 -0700
Message-ID: <1477687224.7065.261.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35945 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752771AbcJ1Uk0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 16:40:26 -0400
Received: by mail-pf0-f196.google.com with SMTP id n85so2121887pfi.3
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 13:40:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

At accept() time, it is possible the parent has a non zero
sk_err_soft, leftover from a prior error.

Make sure we do not leave this value in the child, as it
makes future getsockopt(SO_ERROR) calls quite unreliable.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index d8e4532e89e7c28737c95c723e5f5b3d184a7805..662ccf1c40ed1b66ee253b063dcbfbd186deccee 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1543,6 +1543,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		RCU_INIT_POINTER(newsk->sk_reuseport_cb, NULL);
 
 		newsk->sk_err	   = 0;
+		newsk->sk_err_soft = 0;
 		newsk->sk_priority = 0;
 		newsk->sk_incoming_cpu = raw_smp_processor_id();
 		atomic64_set(&newsk->sk_cookie, 0);
