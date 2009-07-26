From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH] netxen: reset ring consumer during cleanup
Date: Sun, 26 Jul 2009 11:20:56 -0700
Message-ID: <1248632456-24417-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:52931 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753891AbZGZSU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jul 2009 14:20:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reset consumer of status rings to 0 when cleaning
up sw resources. Status rings are not deleted
during suspend since they have napi objects.

This ensures correct rx processing across suspen-resume.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_init.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 5d3343e..7acf204 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -184,6 +184,13 @@ void netxen_free_sw_resources(struct netxen_adapter *adapter)
 	kfree(recv_ctx->rds_rings);
 
 skip_rds:
+	if (recv_ctx->sds_rings == NULL)
+		goto skip_sds;
+
+	for(ring = 0; ring < adapter->max_sds_rings; ring++)
+		recv_ctx->sds_rings[ring].consumer = 0;
+
+skip_sds:
 	if (adapter->tx_ring == NULL)
 		return;
 
-- 
1.6.0.2

