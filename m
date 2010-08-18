From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 1/2] netxen: fix inconsistent lock state
Date: Tue, 17 Aug 2010 23:51:51 -0700
Message-ID: <1282114312-23500-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:7997 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750889Ab0HRGvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 02:51:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spin lock rds_ring->lock is used in poll routine, so other users should
use spin_lock_bh(). While posting rx buffers from netxen_nic_attach,
rds_ring->lock is not required, so cleaning it instead of fixing it by
spin_lock_bh().

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_init.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index c865dda..cabae7b 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1805,8 +1805,6 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid,
 	netxen_ctx_msg msg = 0;
 	struct list_head *head;
 
-	spin_lock(&rds_ring->lock);
-
 	producer = rds_ring->producer;
 
 	head = &rds_ring->free_list;
@@ -1853,8 +1851,6 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid,
 					NETXEN_RCV_PRODUCER_OFFSET), msg);
 		}
 	}
-
-	spin_unlock(&rds_ring->lock);
 }
 
 static void
-- 
1.6.0.2

