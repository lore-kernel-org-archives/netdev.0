From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 08/13] netxen: hold tx lock while sending firmware commands
Date: Mon, 12 Jan 2009 11:23:06 -0800
Message-ID: <1231788191-23794-9-git-send-email-dhananjay@netxen.com>
References: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:56008 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753509AbZALTew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 14:34:52 -0500
In-Reply-To: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some firmware commands like mac address addition/deletion are sent
on the transmit ring. So need to hold the tx lock before touching
tx producer/consumer indices.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hw.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 1ce3ab1..e8c7005 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -503,6 +503,8 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 
 	i = 0;
 
+	netif_tx_lock_bh(adapter->netdev);
+
 	producer = adapter->cmd_producer;
 	do {
 		cmd_desc = &cmd_desc_arr[i];
@@ -527,6 +529,8 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 
 	netxen_nic_update_cmd_producer(adapter, adapter->cmd_producer);
 
+	netif_tx_unlock_bh(adapter->netdev);
+
 	return 0;
 }
 
-- 
1.6.0.2

