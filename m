From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net] unix_diag: fix info leak
Date: Mon, 30 Sep 2013 22:05:40 +0200
Message-ID: <1380571540-15532-1-git-send-email-minipli@googlemail.com>
Cc: Mathias Krause <minipli@googlemail.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:51720 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755956Ab3I3UFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 16:05:54 -0400
Received: by mail-bk0-f41.google.com with SMTP id na10so2368234bkb.28
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 13:05:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When filling the netlink message we miss to wipe the pad field,
therefore leak one byte of heap memory to userland. Fix this by
setting pad to 0.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
Probably material for stable as well (v3.3+).

 net/unix/diag.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index d591091..86fa0f3 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -124,6 +124,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 	rep->udiag_family = AF_UNIX;
 	rep->udiag_type = sk->sk_type;
 	rep->udiag_state = sk->sk_state;
+	rep->pad = 0;
 	rep->udiag_ino = sk_ino;
 	sock_diag_save_cookie(sk, rep->udiag_cookie);
 
-- 
1.7.10.4
