From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH v2 2/5] net: thunderx: Wait for delayed work to finish before destroying it
Date: Wed,  2 Dec 2015 15:36:14 +0530
Message-ID: <1449050777-37836-3-git-send-email-sunil.kovvuri@gmail.com>
References: <1449050777-37836-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449050777-37836-1-git-send-email-sunil.kovvuri@gmail.com>
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
index 2574a7e..6534b73 100644
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
