From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next 5/6] 6lowpan: get extra headroom in allocated frame
Date: Mon,  9 Jul 2012 14:22:30 +0400
Message-ID: <1341829351-18485-6-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1341829351-18485-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33420 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045Ab2GIK0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 06:26:44 -0400
Received: by mail-bk0-f46.google.com with SMTP id j10so5787740bkw.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 03:26:44 -0700 (PDT)
In-Reply-To: <1341829351-18485-1-git-send-email-alex.bluesman.smirnov@gmail.com>
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
index e7de085..90ca7ba 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -660,8 +660,8 @@ lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u8 tag)
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
