From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 4/5] qlcnic: Clear link status when interface is down
Date: Fri, 22 Mar 2013 11:57:56 -0400
Message-ID: <1363967877-16812-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1363967877-16812-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:26042 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S933876Ab3CVQVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 12:21:19 -0400
In-Reply-To: <1363967877-16812-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o When interface is down, mailbox command to get context statistics
  fails. So restrict driver from issuing get statistics command when
  interface is down.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index d980723..d8b9e3b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1412,6 +1412,7 @@ void __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	smp_mb();
 	spin_lock(&adapter->tx_clean_lock);
 	netif_carrier_off(netdev);
+	adapter->ahw->linkup = 0;
 	netif_tx_disable(netdev);
 
 	qlcnic_free_mac_list(adapter);
-- 
1.5.6
