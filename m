From: kaber@trash.net
Subject: [PATCH 25/84] netfilter: xtables: reduce holes in struct xt_target
Date: Mon, 10 May 2010 22:17:56 +0200
Message-ID: <1273522735-24672-26-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54523 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756726Ab0EJUTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:04 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

This will save one full padding chunk (8 bytes on x86_64) per target.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/x_tables.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index cf91473..f8f5551 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -331,6 +331,7 @@ struct xt_target {
 	struct list_head list;
 
 	const char name[XT_FUNCTION_MAXNAMELEN-1];
+	u_int8_t revision;
 
 	/* Returns verdict. Argument order changed since 2.6.9, as this
 	   must now handle non-linear skbs, using skb_copy_bits and
@@ -363,7 +364,6 @@ struct xt_target {
 	unsigned short proto;
 
 	unsigned short family;
-	u_int8_t revision;
 };
 
 /* Furniture shopping... */
-- 
1.7.0.4

