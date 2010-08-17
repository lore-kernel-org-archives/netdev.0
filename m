From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv3 NEXT 5/7] qlcnic: fix link status message
Date: Tue, 17 Aug 2010 03:34:23 -0700
Message-ID: <1282041265-32591-6-git-send-email-amit.salecha@qlogic.com>
References: <1282041265-32591-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:33667 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757412Ab0HQKe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 06:34:27 -0400
In-Reply-To: <1282041265-32591-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Display interface name with netdev_info() for link status message.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index a30bde5..bf4077a 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1944,14 +1944,14 @@ void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup)
 	struct net_device *netdev = adapter->netdev;
 
 	if (adapter->ahw.linkup && !linkup) {
-		dev_info(&netdev->dev, "NIC Link is down\n");
+		netdev_info(netdev, "NIC Link is down\n");
 		adapter->ahw.linkup = 0;
 		if (netif_running(netdev)) {
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 		}
 	} else if (!adapter->ahw.linkup && linkup) {
-		dev_info(&netdev->dev, "NIC Link is up\n");
+		netdev_info(netdev, "NIC Link is up\n");
 		adapter->ahw.linkup = 1;
 		if (netif_running(netdev)) {
 			netif_carrier_on(netdev);
-- 
1.6.0.2

