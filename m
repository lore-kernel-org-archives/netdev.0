From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net v2 1/8] qlcnic: Fix usage of netif_tx_{wake,stop} api during link change.
Date: Mon, 16 Dec 2013 15:36:56 -0500
Message-ID: <355a93b9643725ad7fc74b3384a93453cc66ecb4.1387256276.git.himanshu.madhani@qlogic.com>
References: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:54259 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752123Ab3LPVJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:09:53 -0500
In-Reply-To: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Driver was using netif_tx_{stop,wake}_all_queues() api
  during link change event. Remove these api calls to
  manage queue start/stop event, as core networking stack
  will manage this based on netif_carrier_{on,off} call.
  These API's were modified as part of commit id
  012ec81223aa45d2b80aeafb77392fd1a19c7b10 ("qlcnic: Multi Tx
  queue support for 82xx Series adapter.")

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 0149c94..eda6c69 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -687,17 +687,11 @@ void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup)
 	if (adapter->ahw->linkup && !linkup) {
 		netdev_info(netdev, "NIC Link is down\n");
 		adapter->ahw->linkup = 0;
-		if (netif_running(netdev)) {
-			netif_carrier_off(netdev);
-			netif_tx_stop_all_queues(netdev);
-		}
+		netif_carrier_off(netdev);
 	} else if (!adapter->ahw->linkup && linkup) {
 		netdev_info(netdev, "NIC Link is up\n");
 		adapter->ahw->linkup = 1;
-		if (netif_running(netdev)) {
-			netif_carrier_on(netdev);
-			netif_wake_queue(netdev);
-		}
+		netif_carrier_on(netdev);
 	}
 }
 
-- 
1.8.1.4
