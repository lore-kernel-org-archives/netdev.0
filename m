From: kaber@trash.net
Subject: [PATCH 07/17] netfilter: xt_sctp: use WORD_ROUND macro to calculate length of multiple of 4 bytes
Date: Tue, 15 Jun 2010 17:38:33 +0200
Message-ID: <1276616323-20880-8-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42174 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932261Ab0FOP3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 11:29:54 -0400
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

Use  WORD_ROUND to round an int up to the next multiple of 4.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_sctp.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_sctp.c b/net/netfilter/xt_sctp.c
index c04fcf3..ef36a56 100644
--- a/net/netfilter/xt_sctp.c
+++ b/net/netfilter/xt_sctp.c
@@ -3,6 +3,7 @@
 #include <linux/skbuff.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
+#include <net/sctp/sctp.h>
 #include <linux/sctp.h>
 
 #include <linux/netfilter/x_tables.h>
@@ -67,7 +68,7 @@ match_packet(const struct sk_buff *skb,
 			 ++i, offset, sch->type, htons(sch->length),
 			 sch->flags);
 #endif
-		offset += (ntohs(sch->length) + 3) & ~3;
+		offset += WORD_ROUND(ntohs(sch->length));
 
 		pr_debug("skb->len: %d\toffset: %d\n", skb->len, offset);
 
-- 
1.7.0.4

