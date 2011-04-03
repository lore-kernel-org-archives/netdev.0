From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 2/2] be2net: Fix suspend/resume operation
Date: Sun, 3 Apr 2011 17:24:39 +0530
Message-ID: <afcca139-dadd-48ca-87d5-be101f5ab3a0@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	"Sarveswara Rao Mygapula" <sarveswararao.mygapula@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:1963 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752102Ab1DCLzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 07:55:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eq_next_idx is not getting reset to zero during suspend.
This causes resume to fail. Added the fix.

Signed-off-by: Sarveswara Rao Mygapula <sarveswararao.mygapula@emulex.com>
Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 351c1f2..3e6c1cb 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2356,6 +2356,7 @@ static int be_clear(struct be_adapter *adapter)
 	be_mcc_queues_destroy(adapter);
 	be_rx_queues_destroy(adapter);
 	be_tx_queues_destroy(adapter);
+	adapter->eq_next_idx = 0;
 
 	if (be_physfn(adapter) && adapter->sriov_enabled)
 		for (vf = 0; vf < num_vfs; vf++)
-- 
1.6.0.2

