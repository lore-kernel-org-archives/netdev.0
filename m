From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v2 4/7] 6lowpan: get extra headroom in allocated frame
Date: Wed, 11 Jul 2012 11:22:45 +0400
Message-ID: <1341991368-11800-5-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35913 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756601Ab2GKH1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 03:27:01 -0400
Received: by wibhr14 with SMTP id hr14so807533wib.1
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 00:27:00 -0700 (PDT)
In-Reply-To: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_skb_ip_align() instead of alloc_skb() to get some
extra headroom in case we need to forward this frame in a tunnel or
something else.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index b872515..ae3f4eb 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -661,8 +661,8 @@ lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u8 tag)
 	frame->tag = tag;
 
 	/* allocate buffer for frame assembling */
-	frame->skb = alloc_skb(frame->length +
-			       sizeof(struct ipv6hdr), GFP_ATOMIC);
+	frame->skb = netdev_alloc_skb_ip_align(skb->dev, frame->length +
+					       sizeof(struct ipv6hdr));
 
 	if (!frame->skb)
 		goto skb_err;
-- 
1.7.2.3
