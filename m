From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Fix initialization of the wrong spin lock
Date: Tue, 2 Sep 2014 09:40:22 -0500
Message-ID: <20140902144022.10877.58098.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0183.outbound.protection.outlook.com ([207.46.163.183]:30246
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751500AbaIBOk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 10:40:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During allocation and initialization of the network driver structures,
the wrong pointer is used to initialize a spin lock. Fix the spin lock
initialization by using the proper pointer.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 8aa6a93..bdf9cfa 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -172,7 +172,7 @@ static struct xgbe_channel *xgbe_alloc_rings(struct xgbe_prv_data *pdata)
 		}
 
 		if (i < pdata->rx_ring_count) {
-			spin_lock_init(&tx_ring->lock);
+			spin_lock_init(&rx_ring->lock);
 			channel->rx_ring = rx_ring++;
 		}
 
