From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net-next] net: Remove 'unlikely' qualifier in skb_steal_sock()
Date: Sun, 24 Jun 2012 16:03:07 -0700
Message-ID: <1340578987-2495-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, shemminger@vyatta.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42988 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587Ab2FXW6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 18:58:13 -0400
Received: by pbbrp8 with SMTP id rp8so5755151pbb.19
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2012 15:58:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With early demux enabled by default for TCP flows, there is high chance that
skb->sk will be non-null. 'unlikely()' was removed from __inet_lookup_skb() but
maybe it can be removed from skb_steal_sock() as well.

Note: skb_steal_sock() is also called by __inet6_lookup_skb() and
__udp4_lib_lookup_skb() but they are protected by their own 'unlikely' calls.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 include/net/sock.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 87b424a..2108603 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2154,7 +2154,7 @@ static inline void sk_change_net(struct sock *sk, struct net *net)
 
 static inline struct sock *skb_steal_sock(struct sk_buff *skb)
 {
-	if (unlikely(skb->sk)) {
+	if (skb->sk) {
 		struct sock *sk = skb->sk;
 
 		skb->destructor = NULL;
-- 
1.7.0.4
