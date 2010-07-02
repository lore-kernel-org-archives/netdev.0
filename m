From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: use skb_dst_copy() in ip_copy_metadata()
Date: Fri, 02 Jul 2010 11:48:22 +0200
Message-ID: <1278064102.2530.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42683 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756910Ab0GBJs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 05:48:27 -0400
Received: by fxm14 with SMTP id 14so2137366fxm.19
        for <netdev@vger.kernel.org>; Fri, 02 Jul 2010 02:48:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid touching dst refcount in ip_fragment().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7d1f4b4..d647852 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -411,7 +411,7 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	to->priority = from->priority;
 	to->protocol = from->protocol;
 	skb_dst_drop(to);
-	skb_dst_set(to, dst_clone(skb_dst(from)));
+	skb_dst_copy(to, from);
 	to->dev = from->dev;
 	to->mark = from->mark;
 


