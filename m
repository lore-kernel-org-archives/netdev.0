From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH net-2.6 1/4] netxen: fix tx ring memory leak
Date: Fri,  8 Jan 2010 00:10:14 -0800
Message-ID: <1262938217-10089-2-git-send-email-amit.salecha@qlogic.com>
References: <1262938217-10089-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:25993 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753204Ab0AHIKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2010 03:10:21 -0500
In-Reply-To: <1262938217-10089-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o While unloading driver or resetting the context, tx ring was not
  getting free.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_init.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 02f8d4b..925b699 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -184,6 +184,8 @@ skip_rds:
 
 	tx_ring = adapter->tx_ring;
 	vfree(tx_ring->cmd_buf_arr);
+	kfree(tx_ring);
+	adapter->tx_ring = NULL;
 }
 
 int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
-- 
1.6.0.2

