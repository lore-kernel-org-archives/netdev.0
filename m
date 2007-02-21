From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2/2] NetXen: Driver ifconfig fix
Date: Wed, 21 Feb 2007 06:54:06 -0800
Message-ID: <200702211454.l1LEs6DA029834@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:17341 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751289AbXBUOyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 09:54:07 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

---

 netxen_nic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b2fc2bc..1bf3d49 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -525,6 +525,8 @@ static void __devexit netxen_nic_remove(
 	if (adapter == NULL)
 		return;
 
+	if (adapter->irq)
+		free_irq(adapter->irq, adapter);
 	netxen_nic_stop_all_ports(adapter);
 	/* leave the hw in the same state as reboot */
 	netxen_pinit_from_rom(adapter, 0);
@@ -672,8 +674,6 @@ static int netxen_nic_close(struct net_d
 
 	if (!adapter->active_ports) {
 		netxen_nic_disable_int(adapter);
-		if (adapter->irq)
-			free_irq(adapter->irq, adapter);
 		cmd_buff = adapter->cmd_buf_arr;
 		for (i = 0; i < adapter->max_tx_desc_count; i++) {
 			buffrag = cmd_buff->frag_array;
