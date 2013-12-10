From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net 1/5] qlcnic: Use correct netif api to enable tx queues.
Date: Tue, 10 Dec 2013 12:33:01 -0500
Message-ID: <a124e077076f2a1d1107200e629945108bd467bd.1386648865.git.himanshu.madhani@qlogic.com>
References: <cover.1386648865.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:57703 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755026Ab3LJSFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 13:05:50 -0500
In-Reply-To: <cover.1386648865.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o commit id 012ec81223aa45d2b80aeafb77392fd1a19c7b10
  ("qlcnic: Multi Tx queue support for 82xx Series adapter.")
  enabled multiple tx queue API's for qlcnic driver.
  During link change event, driver will stop/start Tx queues
  which manages Link up event is received after Tx context is created
  driver needs to call netif_tx_wake_all_queues()

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 0149c94..312c6cd 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -696,7 +696,7 @@ void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup)
 		adapter->ahw->linkup = 1;
 		if (netif_running(netdev)) {
 			netif_carrier_on(netdev);
-			netif_wake_queue(netdev);
+			netif_tx_wake_all_queues(netdev);
 		}
 	}
 }
-- 
1.8.1.4
