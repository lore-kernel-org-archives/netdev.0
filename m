From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 6/8] netxen: fix warning in ioaddr for NX3031 chip
Date: Wed, 24 Mar 2010 06:29:21 -0700
Message-ID: <1269437363-2606-7-git-send-email-amit.salecha@qlogic.com>
References: <1269437363-2606-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:49140 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756250Ab0CXN30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 09:29:26 -0400
In-Reply-To: <1269437363-2606-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

crb_intr_mask/crb_sts_consumer is predefined for NX2031
not for NX3031. Keep NX2031 specific code in if{}.
---
 drivers/net/netxen/netxen_nic_ctx.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 2a8ef5f..f26e547 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -669,13 +669,15 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 		}
 		sds_ring->desc_head = (struct status_desc *)addr;
 
-		sds_ring->crb_sts_consumer =
-			netxen_get_ioaddr(adapter,
-			recv_crb_registers[port].crb_sts_consumer[ring]);
+		if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+			sds_ring->crb_sts_consumer =
+				netxen_get_ioaddr(adapter,
+				recv_crb_registers[port].crb_sts_consumer[ring]);
 
-		sds_ring->crb_intr_mask =
-			netxen_get_ioaddr(adapter,
-			recv_crb_registers[port].sw_int_mask[ring]);
+			sds_ring->crb_intr_mask =
+				netxen_get_ioaddr(adapter,
+				recv_crb_registers[port].sw_int_mask[ring]);
+		}
 	}
 
 
-- 
1.6.0.2

