From: roy.qing.li@gmail.com
Subject: [PATCH net-next v2] ipv6: ip6_forward: perform skb->pkt_type check at the beginning
Date: Tue, 11 Mar 2014 10:40:08 +0800
Message-ID: <1394505608-7709-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:62436 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753823AbaCKCkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 22:40:16 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so8070523pab.41
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 19:40:15 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id zl2sm53386485pac.7.2014.03.10.19.40.13
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 10 Mar 2014 19:40:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com> 

Packets which have L2 address different from ours should be
already filtered before entering into ip6_forward().

Perform that check at the beginning to avoid processing such packets.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/ip6_output.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 2bc1070..90dd551 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -367,6 +367,9 @@ int ip6_forward(struct sk_buff *skb)
 	if (net->ipv6.devconf_all->forwarding == 0)
 		goto error;
 
+	if (skb->pkt_type != PACKET_HOST)
+		goto drop;
+
 	if (skb_warn_if_lro(skb))
 		goto drop;
 
@@ -376,9 +379,6 @@ int ip6_forward(struct sk_buff *skb)
 		goto drop;
 	}
 
-	if (skb->pkt_type != PACKET_HOST)
-		goto drop;
-
 	skb_forward_csum(skb);
 
 	/*
-- 
1.7.10.4
