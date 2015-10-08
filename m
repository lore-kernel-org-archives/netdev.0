From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 3/9] net/nfnetlink: lockdep_nfnl_is_held can be boolean
Date: Thu,  8 Oct 2015 21:28:56 +0800
Message-ID: <1444310942-4428-4-git-send-email-bywxiaobai@163.com>
References: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, herbert@gondor.apana.org.au,
	johannes.berg@intel.com, daniel@iogearbox.net,
	gerrit@erg.abdn.ac.uk, socketcan@hartkopp.net, mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:35983 "EHLO m12-14.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757712AbbJHNh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 09:37:56 -0400
In-Reply-To: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes lockdep_nfnl_is_held return bool to improve
readability due to this particular function only using either
one or zero as its return value.

No functional change.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 include/linux/netfilter/nfnetlink.h | 6 +++---
 net/netfilter/nfnetlink.c           | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index e955d47..249d1bb 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -45,11 +45,11 @@ int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u32 portid,
 void nfnl_lock(__u8 subsys_id);
 void nfnl_unlock(__u8 subsys_id);
 #ifdef CONFIG_PROVE_LOCKING
-int lockdep_nfnl_is_held(__u8 subsys_id);
+bool lockdep_nfnl_is_held(__u8 subsys_id);
 #else
-static inline int lockdep_nfnl_is_held(__u8 subsys_id)
+static inline bool lockdep_nfnl_is_held(__u8 subsys_id)
 {
-	return 1;
+	return true;
 }
 #endif /* CONFIG_PROVE_LOCKING */
 
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 70277b1..f1d9e88 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -64,7 +64,7 @@ void nfnl_unlock(__u8 subsys_id)
 EXPORT_SYMBOL_GPL(nfnl_unlock);
 
 #ifdef CONFIG_PROVE_LOCKING
-int lockdep_nfnl_is_held(u8 subsys_id)
+bool lockdep_nfnl_is_held(u8 subsys_id)
 {
 	return lockdep_is_held(&table[subsys_id].mutex);
 }
-- 
1.9.1
