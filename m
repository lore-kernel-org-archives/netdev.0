From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 2/9] qlcnic: Set __QLCNIC_DEV_UP in adapter state before enabling interrupts
Date: Fri, 19 Jul 2013 16:56:27 -0400
Message-ID: <1374267394-27697-3-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Pratik Pujar <pratik.pujar@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:21744 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751617Ab3GSVYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 17:24:04 -0400
In-Reply-To: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pratik Pujar <pratik.pujar@qlogic.com>

NAPI poll function does not re-enable the interrupt, if __QLCNIC_DEV_UP is not set
in adapter state. This was preventing driver from receiving any packet.

Signed-off-by: Pratik Pujar <pratik.pujar@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 4528f8e..41635f2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1531,12 +1531,12 @@ int __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	if (netdev->features & NETIF_F_LRO)
 		qlcnic_config_hw_lro(adapter, QLCNIC_LRO_ENABLED);
 
+	set_bit(__QLCNIC_DEV_UP, &adapter->state);
 	qlcnic_napi_enable(adapter);
 
 	qlcnic_linkevent_request(adapter, 1);
 
 	adapter->ahw->reset_context = 0;
-	set_bit(__QLCNIC_DEV_UP, &adapter->state);
 	return 0;
 }
 
-- 
1.7.1
