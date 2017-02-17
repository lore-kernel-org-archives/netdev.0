From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: use page_ref_inc() in tcp_sendmsg()
Date: Fri, 17 Feb 2017 09:11:42 -0800
Message-ID: <1487351502.1311.84.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32820 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934122AbdBQRLo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 12:11:44 -0500
Received: by mail-pg0-f68.google.com with SMTP id 5so5385913pgj.0
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 09:11:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

sk_page_frag_refill() allocates either a compound page or an order-0
page. We can use page_ref_inc() which is slightly faster than get_page()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index d44a6989e76d69aa44e2a26d37b4204376c94966..da385ae997a3d61f0217a2e585088a82e6d50cd3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1288,7 +1288,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 			} else {
 				skb_fill_page_desc(skb, i, pfrag->page,
 						   pfrag->offset, copy);
-				get_page(pfrag->page);
+				page_ref_inc(pfrag->page);
 			}
 			pfrag->offset += copy;
 		}
