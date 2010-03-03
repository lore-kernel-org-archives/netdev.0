From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 8/8] x25: use limited socket backlog
Date: Wed,  3 Mar 2010 14:35:11 +0800
Message-ID: <1267598111-12503-8-git-send-email-yi.zhu@intel.com>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-3-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-4-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-5-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-6-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-7-git-send-email-yi.zhu@intel.com>
Cc: Zhu Yi <yi.zhu@intel.com>, Andrew Hendry <andrew.hendry@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21735 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754535Ab0CCGdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 01:33:41 -0500
In-Reply-To: <1267598111-12503-7-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make x25 adapt to the limited socket backlog change.

Cc: Andrew Hendry <andrew.hendry@gmail.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 net/x25/x25_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index 3e1efe5..5688123 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -53,7 +53,7 @@ static int x25_receive_data(struct sk_buff *skb, struct x25_neigh *nb)
 		if (!sock_owned_by_user(sk)) {
 			queued = x25_process_rx_frame(sk, skb);
 		} else {
-			sk_add_backlog(sk, skb);
+			__sk_add_backlog(sk, skb);
 		}
 		bh_unlock_sock(sk);
 		sock_put(sk);
-- 
1.6.3.3

