From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v2 4/5] 6lowpan: remove skb->dev assignment
Date: Sat, 26 Oct 2013 15:54:01 +0200
Message-ID: <1382795642-12501-5-git-send-email-alex.aring@gmail.com>
References: <1382795642-12501-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:64008 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424Ab3JZNyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 09:54:21 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so1268798ead.21
        for <netdev@vger.kernel.org>; Sat, 26 Oct 2013 06:54:20 -0700 (PDT)
In-Reply-To: <1382795642-12501-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the assignment of skb->dev. We don't need it here because
we use the netdev_alloc_skb_ip_align function which already sets the
skb->dev.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Reviewed-by: Werner Almesberger <werner@almesberger.net>
---
 net/ieee802154/6lowpan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 1884a84..665b118 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -785,7 +785,6 @@ lowpan_alloc_new_frame(struct sk_buff *skb, u16 len, u16 tag)
 		goto skb_err;
 
 	frame->skb->priority = skb->priority;
-	frame->skb->dev = skb->dev;
 
 	/* reserve headroom for uncompressed ipv6 header */
 	skb_reserve(frame->skb, sizeof(struct ipv6hdr));
-- 
1.8.4.1
