From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 1/2] udp: do not expect udp headers on ioctl SIOCINQ
Date: Thu,  7 Apr 2016 18:12:58 -0400
Message-ID: <1460067179-67789-2-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1460067179-67789-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, tom@herbertland.com, samanthakumar@google.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:32906 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbcDGWNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 18:13:05 -0400
Received: by mail-qk0-f193.google.com with SMTP id d3so4295079qke.0
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 15:13:04 -0700 (PDT)
In-Reply-To: <1460067179-67789-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

On udp sockets, ioctl SIOCINQ returns the payload size of the first
packet. Since commit e6afc8ace6dd pulled the headers, the result is
incorrect when subtracting header length. Remove that operation.

Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/udp.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 3563788d..d2d294b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1282,8 +1282,6 @@ int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 			 * of this packet since that is all
 			 * that will be read.
 			 */
-			amount -= sizeof(struct udphdr);
-
 		return put_user(amount, (int __user *)arg);
 	}
 
-- 
2.8.0.rc3.226.g39d4020
