From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 5/7] qlcnic: fix default operating state of interface
Date: Wed, 22 Jun 2011 05:52:21 -0700
Message-ID: <1308747144-23785-5-git-send-email-anirban.chakraborty@qlogic.com>
References: <1308747144-23785-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: David Miller <davem@davemloft.net>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:55824 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1755128Ab1FVNAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 09:00:22 -0400
In-Reply-To: <1308747144-23785-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

Currently interface shows status as RUNNING, even if there is no link.
To fix this, netif_carrier_off should be called qlcnic_open().

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index a050746..5dcb853 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1485,8 +1485,6 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 
 	netdev->irq = adapter->msix_entries[0].vector;
 
-	netif_carrier_off(netdev);
-
 	err = register_netdev(netdev);
 	if (err) {
 		dev_err(&pdev->dev, "failed to register net device\n");
@@ -1816,6 +1814,8 @@ static int qlcnic_open(struct net_device *netdev)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int err;
 
+	netif_carrier_off(netdev);
+
 	err = qlcnic_attach(adapter);
 	if (err)
 		return err;
-- 
1.7.4.1

