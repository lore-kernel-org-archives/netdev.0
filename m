From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next v2 2/3] net: use skb->priority for overloading skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Thu, 12 Feb 2015 06:32:14 +0200
Message-ID: <1423715535-884-3-git-send-email-eyal.birger@gmail.com>
References: <1423715535-884-1-git-send-email-eyal.birger@gmail.com>
Cc: netdev@vger.kernel.org, edumazet@google.com,
	shmulik.ladkani@gmail.com, Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:37886 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074AbbBLEcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 23:32:35 -0500
Received: by mail-we0-f179.google.com with SMTP id u56so7553093wes.10
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 20:32:34 -0800 (PST)
In-Reply-To: <1423715535-884-1-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 977750076d98 ("af_packet: add interframe drop cmsg (v6)")
unionized skb->mark and skb->dropcount in order to allow recording
of the socket drop count while maintaining struct sk_buff size.

In order to allow for the skb->mark to be fetched by user-space code
it needs to be detached from this union; skb->priority is used
instead.

Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
----
The purpose of overloading skb->priority is solely for retaining
struct sk_buff size; skb->priority is not used after the skb queued
to the socket and has the same guarentee of not being shared as
skb->mark.
---
 include/linux/skbuff.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1bb36ed..23f1a94 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -621,7 +621,7 @@ struct sk_buff {
 			__u16	csum_offset;
 		};
 	};
-	__u32			priority;
+	__u32			mark;
 	int			skb_iif;
 	__u32			hash;
 	__be16			vlan_proto;
@@ -636,7 +636,7 @@ struct sk_buff {
 	__u32			secmark;
 #endif
 	union {
-		__u32		mark;
+		__u32		priority;
 		__u32		dropcount;
 		__u32		reserved_tailroom;
 	};
-- 
2.1.4
