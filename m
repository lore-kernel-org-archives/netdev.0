From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 2/5] 6lowpan: remove unnecessary check on err >= 0
Date: Thu, 24 Oct 2013 22:51:41 +0200
Message-ID: <1382647904-11311-3-git-send-email-alex.aring@gmail.com>
References: <1382647904-11311-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:46488 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755269Ab3JXUwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 16:52:09 -0400
Received: by mail-ea0-f181.google.com with SMTP id d10so44214eaj.12
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 13:52:08 -0700 (PDT)
In-Reply-To: <1382647904-11311-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The err variable can only be zero in this case.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Reviewed-by: Werner Almesberger <werner@almesberger.net>
---
 net/ieee802154/6lowpan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index d288035..9057f83 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1179,7 +1179,7 @@ lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
 	head[0] &= ~LOWPAN_DISPATCH_FRAG1;
 	head[0] |= LOWPAN_DISPATCH_FRAGN;
 
-	while ((payload_length - offset > 0) && (err >= 0)) {
+	while (payload_length - offset > 0) {
 		int len = LOWPAN_FRAG_SIZE;
 
 		head[4] = offset / 8;
-- 
1.8.4.1
