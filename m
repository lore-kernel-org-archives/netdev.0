From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net] packet: propagate sock_cmsg_send() error
Date: Wed, 20 Jul 2016 18:01:18 -0400
Message-ID: <1469052078-31269-1-git-send-email-soheil.kdev@gmail.com>
Cc: willemb@google.com, Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36050 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbcGTWBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 18:01:25 -0400
Received: by mail-qk0-f194.google.com with SMTP id q8so5009740qke.3
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 15:01:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

sock_cmsg_send() can return different error codes and not only
-EINVAL, and we should properly propagate them.

Fixes: c14ac9451c34 ("sock: enable timestamping using control messages")
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 53e87ce..b43c401 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1930,10 +1930,8 @@ retry:
 	sockc.tsflags = sk->sk_tsflags;
 	if (msg->msg_controllen) {
 		err = sock_cmsg_send(sk, msg, &sockc);
-		if (unlikely(err)) {
-			err = -EINVAL;
+		if (unlikely(err))
 			goto out_unlock;
-		}
 	}
 
 	skb->protocol = proto;
-- 
2.8.0.rc3.226.g39d4020
