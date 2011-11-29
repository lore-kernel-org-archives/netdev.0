From: igorm@etf.rs
Subject: [PATCH] Fix jump_label handling in dev.c
Date: Tue, 29 Nov 2011 11:30:49 +0100
Message-ID: <1322562649-20876-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Cc: eric.dumazet@gmail.com, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:53495 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753107Ab1K2Kay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 05:30:54 -0500
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

static_branch instead of atomic_read.
Eric forgot to replace that.

Signed-off-by: Igor Maravic <igorm@etf.rs>

:100644 100644 579ce33... d358088... M	net/core/dev.c

diff --git a/net/core/dev.c b/net/core/dev.c
index 579ce33..d358088 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1482,12 +1482,12 @@ EXPORT_SYMBOL(net_disable_timestamp);
 static inline void net_timestamp_set(struct sk_buff *skb)
 {
 	skb->tstamp.tv64 = 0;
-	if (atomic_read(&netstamp_needed))
+	if (static_branch(&netstamp_needed))
 		__net_timestamp(skb);
 }
 
 #define net_timestamp_check(COND, SKB)			\
-	if (atomic_read(&netstamp_needed)) {		\
+	if (static_branch(&netstamp_needed)) {		\
 		if ((COND) && !(SKB)->tstamp.tv64)	\
 			__net_timestamp(SKB);		\
 	}						\
-- 
1.7.5.4
