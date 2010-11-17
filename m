From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 4/5] qlcnic: lro off message log from set rx
 checsum
Date: Tue, 16 Nov 2010 16:08:46 -0800
Message-ID: <alpine.OSX.2.00.1011161522360.88679@macintosh-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:19293 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757143Ab0KQAJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 19:09:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Log LRO off message while disabling rx checksum only when
LRO is already enabled.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index ec21d24..c389296 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -925,9 +925,10 @@ static int qlcnic_set_rx_csum(struct net_device *dev, u32 data)
 
 		dev->features &= ~NETIF_F_LRO;
 		qlcnic_send_lro_cleanup(adapter);
+		dev_info(&adapter->pdev->dev,
+					"disabling LRO as rx_csum is off\n");
 	}
 	adapter->rx_csum = !!data;
-	dev_info(&adapter->pdev->dev, "disabling LRO as rx_csum is off\n");
 	return 0;
 }
 
-- 
1.5.4.5

