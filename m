From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv4: use unlikely to optimise in ip_forward
Date: Mon, 10 Mar 2014 13:10:09 +0800
Message-ID: <1394428209-9919-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:57664 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbaCJFI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 01:08:59 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so6750662pad.14
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 22:08:59 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id bz4sm60605945pbb.12.2014.03.09.22.08.56
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sun, 09 Mar 2014 22:08:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The condition that skb->pkt_type is not PACKET_HOST in ip_forward, should never
happen, so use unlikely to optimise this check

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/ip_forward.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index be8abe7..b82833a 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -128,7 +128,7 @@ int ip_forward(struct sk_buff *skb)
 	struct ip_options *opt	= &(IPCB(skb)->opt);
 
 	/* that should never happen */
-	if (skb->pkt_type != PACKET_HOST)
+	if (unlikely(skb->pkt_type != PACKET_HOST))
 		goto drop;
 
 	if (skb_warn_if_lro(skb))
-- 
1.7.10.4
