From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH v2 net-next] include/linux/skbuff.h: move CONFIG_XFRM check inside the skb_sec_path()
Date: Wed,  2 Oct 2013 05:58:32 +0400
Message-ID: <1380679112-2393-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:57087 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275Ab3JBFxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 01:53:47 -0400
Received: by mail-lb0-f178.google.com with SMTP id z5so337943lbh.23
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 22:53:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And thus we have only one function definition

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
v1->v2: rebase to net-next head
---
 include/linux/skbuff.h | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 71b1d94..1cd32f9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2708,17 +2708,14 @@ static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
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
