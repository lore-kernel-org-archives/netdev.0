From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 02/13] net: thunderx: Wait for delayed work to finish before destroying it
Date: Mon, 30 Nov 2015 23:48:58 +0530
Message-ID: <1448907549-5296-3-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <y>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>

While VNIC or BGX driver teardown, wait for already scheduled delayed work to
finish before destroying it.

Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c    |    3 +--
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index c561fdc..cfc24a1 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -1074,8 +1074,7 @@ static void nic_remove(struct pci_dev *pdev)
 
 	if (nic->check_link) {
 		/* Destroy work Queue */
-		cancel_delayed_work(&nic->dwork);
-		flush_workqueue(nic->check_link);
+		cancel_delayed_work_sync(&nic->dwork);
 		destroy_workqueue(nic->check_link);
 	}
 
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 1fb72dd..2076ac3 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -695,8 +695,7 @@ static void bgx_lmac_disable(struct bgx *bgx, u8 lmacid)
 	lmac = &bgx->lmac[lmacid];
 	if (lmac->check_link) {
 		/* Destroy work queue */
-		cancel_delayed_work(&lmac->dwork);
-		flush_workqueue(lmac->check_link);
+		cancel_delayed_work_sync(&lmac->dwork);
 		destroy_workqueue(lmac->check_link);
 	}
 
-- 
1.7.1
