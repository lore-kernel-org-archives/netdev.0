From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 1/3] drivers: net: xgene: Read tx/rx delay for ACPI
Date: Tue,  5 Sep 2017 11:16:30 -0700
Message-ID: <1504635392-19089-2-git-send-email-isubramanian@apm.com>
References: <1504635392-19089-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Quan Nguyen <qnguyen@apm.com>, dnelson@redhat.com, patches@apm.com,
 linux-arm-kernel@lists.infradead.org,
 Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1504635392-19089-1-git-send-email-isubramanian@apm.com>
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

This patch fixes reading tx/rx delay values for ACPI.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 6e253d9..655c0fc 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1591,7 +1591,7 @@ static int xgene_get_tx_delay(struct xgene_enet_pdata *pdata)
 	struct device *dev = &pdata->pdev->dev;
 	int delay, ret;
 
-	ret = of_property_read_u32(dev->of_node, "tx-delay", &delay);
+	ret = device_property_read_u32(dev, "tx-delay", &delay);
 	if (ret) {
 		pdata->tx_delay = 4;
 		return 0;
@@ -1612,7 +1612,7 @@ static int xgene_get_rx_delay(struct xgene_enet_pdata *pdata)
 	struct device *dev = &pdata->pdev->dev;
 	int delay, ret;
 
-	ret = of_property_read_u32(dev->of_node, "rx-delay", &delay);
+	ret = device_property_read_u32(dev, "rx-delay", &delay);
 	if (ret) {
 		pdata->rx_delay = 2;
 		return 0;
-- 
2.7.4
