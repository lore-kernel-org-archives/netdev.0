From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/2] netxen: Notify firmware of Flex-10 interface down
Date: Fri, 11 Mar 2011 02:44:36 -0800
Message-ID: <1299840277-30591-2-git-send-email-amit.salecha@qlogic.com>
References: <1299840277-30591-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:2375 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756018Ab1DKWwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 18:52:10 -0400
In-Reply-To: <1299840277-30591-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Notify firmware when a Flex-10 interface is brought down
so that virtual connect manager can display the correct link status.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 33fac32..83348dc 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1032,6 +1032,9 @@ __netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
 
+	if (adapter->capabilities & NX_FW_CAPABILITY_LINK_NOTIFICATION)
+		netxen_linkevent_request(adapter, 0);
+
 	if (adapter->stop_port)
 		adapter->stop_port(adapter);
 
-- 
1.6.3.3

