From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 20/23] tipc: Minor optimization of broadcast link transmit queue statistic
Date: Tue, 27 Dec 2011 12:39:39 -0500
Message-ID: <1325007582-31610-21-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39504 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754841Ab1L0RkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:10 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

The two broadcast link statistics fields that are used to derive the
average length of that link's transmit queue are now updated only after
a successful attempt to send a broadcast message, since there is no need
to update these values when an unsuccessful send attempt leaves the
queue unchanged.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 8f58df2..dd990b0 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -424,11 +424,11 @@ int tipc_bclink_send_msg(struct sk_buff *buf)
 	}
 
 	res = tipc_link_send_buf(bcl, buf);
-	if (likely(res > 0))
+	if (likely(res >= 0)) {
 		bclink_set_last_sent();
-
-	bcl->stats.queue_sz_counts++;
-	bcl->stats.accu_queue_sz += bcl->out_queue_size;
+		bcl->stats.queue_sz_counts++;
+		bcl->stats.accu_queue_sz += bcl->out_queue_size;
+	}
 exit:
 	spin_unlock_bh(&bc_lock);
 	return res;
-- 
1.7.4.4
