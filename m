From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH V3 4/8] llc: use limited socket backlog
Date: Fri,  5 Mar 2010 12:01:43 +0800
Message-ID: <1267761707-15605-4-git-send-email-yi.zhu@intel.com>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
 <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
 <1267761707-15605-3-git-send-email-yi.zhu@intel.com>
Cc: netdev@vger.kernel.org, Zhu Yi <yi.zhu@intel.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:27263 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754141Ab0CEEA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Mar 2010 23:00:28 -0500
In-Reply-To: <1267761707-15605-3-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make llc adapt to the limited socket backlog change.

Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 net/llc/llc_conn.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index a8dde9b..c0539ff 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -827,7 +827,8 @@ void llc_conn_handler(struct llc_sap *sap, struct sk_buff *skb)
 	else {
 		dprintk("%s: adding to backlog...\n", __func__);
 		llc_set_backlog_type(skb, LLC_PACKET);
-		sk_add_backlog(sk, skb);
+		if (sk_add_backlog_limited(sk, skb))
+			goto drop_unlock;
 	}
 out:
 	bh_unlock_sock(sk);
-- 
1.6.3.3

