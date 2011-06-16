From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 5/7] qlcnic: fix default operating state of interface
Date: Thu, 16 Jun 2011 13:37:36 -0700
Message-ID: <1308256659-19895-5-git-send-email-anirban.chakraborty@qlogic.com>
References: <1308256659-19895-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: David Miller <davem@davemloft.net>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:50523 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1758694Ab1FPUp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2011 16:45:29 -0400
In-Reply-To: <1308256659-19895-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

Currently interface shows status as RUNNING, even if there is no link.
To fix this, netif_carrier_off should be called after register_netdev().

netif_carrier_off calls linkwatch_fire_event(dev); only if netdev is registered,
otherwise it skips. linkwatch_fire_event set default state of nic interface.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 8c07c4e..5348dba 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1485,14 +1485,14 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 
 	netdev->irq = adapter->msix_entries[0].vector;
 
-	netif_carrier_off(netdev);
-
 	err = register_netdev(netdev);
 	if (err) {
 		dev_err(&pdev->dev, "failed to register net device\n");
 		return err;
 	}
 
+	netif_carrier_off(netdev);
+
 	return 0;
 }
 
-- 
1.7.4.1

