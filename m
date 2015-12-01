From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 2/6] net: thunderx: Wait for delayed work to finish before
 destroying it
Date: Tue,  1 Dec 2015 14:43:39 +0530
Message-ID: <1448961223-41888-3-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, Sunil.Goutham@caviumnetworks.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <y>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
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
