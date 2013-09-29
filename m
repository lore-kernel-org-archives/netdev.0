From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next] include/linux/skbuff.h: move CONFIG_XFRM check inside the skb_sec_path()
Date: Sun, 29 Sep 2013 18:07:25 +0400
Message-ID: <1380463645-4633-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:38481 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345Ab3I2SA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 14:00:56 -0400
Received: by mail-lb0-f178.google.com with SMTP id z5so3775855lbh.37
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 11:00:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And thus we have only one function definition

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 include/linux/skbuff.h | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2ddb48d..7399045 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2736,17 +2736,14 @@ extern u16 __skb_tx_hash(const struct net_device *dev,
 			 const struct sk_buff *skb,
 			 unsigned int num_tx_queues);
 
-#ifdef CONFIG_XFRM
 static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
 {
+#ifdef CONFIG_XFRM
 	return skb->sp;
-}
 #else
-static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
-{
 	return NULL;
-}
 #endif
+}
 
 /* Keeps track of mac header offset relative to skb->head.
  * It is useful for TSO of Tunneling protocol. e.g. GRE.
-- 
1.8.0.2
