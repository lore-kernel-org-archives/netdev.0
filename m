From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH V3 7/8] x25: use limited socket backlog
Date: Fri,  5 Mar 2010 12:01:46 +0800
Message-ID: <1267761707-15605-7-git-send-email-yi.zhu@intel.com>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
 <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
 <1267761707-15605-3-git-send-email-yi.zhu@intel.com>
 <1267761707-15605-4-git-send-email-yi.zhu@intel.com>
 <1267761707-15605-5-git-send-email-yi.zhu@intel.com>
 <1267761707-15605-6-git-send-email-yi.zhu@intel.com>
Cc: netdev@vger.kernel.org, Zhu Yi <yi.zhu@intel.com>,
	Andrew Hendry <andrew.hendry@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:33299 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505Ab0CEEAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Mar 2010 23:00:31 -0500
In-Reply-To: <1267761707-15605-6-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make x25 adapt to the limited socket backlog change.

Cc: Andrew Hendry <andrew.hendry@gmail.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 net/x25/x25_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index 3e1efe5..a9da0dc 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -53,7 +53,7 @@ static int x25_receive_data(struct sk_buff *skb, struct x25_neigh *nb)
 		if (!sock_owned_by_user(sk)) {
 			queued = x25_process_rx_frame(sk, skb);
 		} else {
-			sk_add_backlog(sk, skb);
+			queued = !sk_add_backlog_limited(sk, skb);
 		}
 		bh_unlock_sock(sk);
 		sock_put(sk);
-- 
1.6.3.3

