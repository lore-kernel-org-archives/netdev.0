From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/4] netlink: fix test alignment in nla_align_64bit()
Date: Wed, 20 Apr 2016 10:57:32 +0200
Message-ID: <1461142655-5067-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20160419.195009.1052027353987244150.davem@davemloft.net>
 <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com, tgraf@suug.ch, jhs@mojatatu.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:56429 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932391AbcDTI5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 04:57:51 -0400
In-Reply-To: <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ALIGN() returns true when the alignment is as expected. The pad
attribute should be added only when the alignment is not 8.

Fixes: 35c5845957c7 ("net: Add helpers for 64-bit aligning netlink attributes.")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/netlink.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index e644b3489acf..694caac31d2c 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1245,7 +1245,7 @@ static inline int nla_validate_nested(const struct nlattr *start, int maxtype,
 static inline int nla_align_64bit(struct sk_buff *skb, int padattr)
 {
 #ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
-	if (IS_ALIGNED((unsigned long)skb->data, 8)) {
+	if (!IS_ALIGNED((unsigned long)skb->data, 8)) {
 		struct nlattr *attr = nla_reserve(skb, padattr, 0);
 		if (!attr)
 			return -EMSGSIZE;
-- 
2.4.2
