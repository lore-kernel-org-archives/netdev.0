From: "Figo.zhang" <figo1802@gmail.com>
Subject: [PATCH]netxen: fix checking
Date: Wed, 10 Jun 2009 22:13:47 +0800
Message-ID: <1244643227.3422.3.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dhananjay Phadke <dhananjay@netxen.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:22488 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976AbZFJONt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 10:13:49 -0400
Received: by rv-out-0506.google.com with SMTP id f9so266056rvb.1
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 07:13:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vfree() does its own 'NULL' check, so no need for check before
calling it.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
---   
 drivers/net/netxen/netxen_nic_init.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 0759c35..7ab0aa4 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -208,14 +208,11 @@ void netxen_free_sw_resources(struct netxen_adapter *adapter)
 	recv_ctx = &adapter->recv_ctx;
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
-		if (rds_ring->rx_buf_arr) {
-			vfree(rds_ring->rx_buf_arr);
-			rds_ring->rx_buf_arr = NULL;
-		}
+		vfree(rds_ring->rx_buf_arr);
+		rds_ring->rx_buf_arr = NULL;
 	}
 
-	if (adapter->cmd_buf_arr)
-		vfree(adapter->cmd_buf_arr);
+	vfree(adapter->cmd_buf_arr);
 	return;
 }
 


