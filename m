From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 2/2] netxen: Fix bug in Tx completion path.
Date: Tue, 30 Sep 2014 03:56:36 -0400
Message-ID: <1412063796-25959-3-git-send-email-manish.chopra@qlogic.com>
References: <1412063796-25959-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <umgwanakikbuti@gmail.com>,
	<Dept-GELinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49491 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751306AbaI3Iat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 04:30:49 -0400
In-Reply-To: <1412063796-25959-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Driver is not updating sw_consumer while processing Tx completion
  when interface is going down. Due to this interface down path gets
  stuck forever waiting for NAPI to complete.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_init.c   |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index ae4ec7b..5c40683 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1794,9 +1794,9 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 			break;
 	}
 
-	if (count && netif_running(netdev)) {
-		tx_ring->sw_consumer = sw_consumer;
+	tx_ring->sw_consumer = sw_consumer;
 
+	if (count && netif_running(netdev)) {
 		smp_mb();
 
 		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev))
-- 
1.7.1
