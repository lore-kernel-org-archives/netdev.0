From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 04/29] net: Add net_ctx macros for skbuffs
Date: Wed,  4 Feb 2015 18:34:05 -0700
Message-ID: <1423100070-31848-5-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36657 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756055AbbBEBf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:35:57 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so39133588igb.3
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:35:56 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb macros will be used later for determining a network context
from skbs.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/skbuff.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85ab7d72b54c..a5dfef469d07 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -665,6 +665,10 @@ struct sk_buff {
 	atomic_t		users;
 };
 
+#define SKB_NET_CTX_DEV(skb)  { .net = dev_net((skb)->dev) }
+#define SKB_NET_CTX_DST(skb)  { .net = dev_net(skb_dst((skb))->dev) }
+#define SKB_NET_CTX_SOCK(skb) { .net = sock_net((skb)->sk) }
+
 #ifdef __KERNEL__
 /*
  *	Handling routines are only of interest to the kernel
-- 
1.9.3 (Apple Git-50)
