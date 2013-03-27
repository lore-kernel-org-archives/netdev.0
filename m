From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/1] drivers: net: ethernet: ti: sparse warning fix for ti ethernet drivers
Date: Wed, 27 Mar 2013 15:28:07 +0530
Message-ID: <1364378287-11194-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fix for the below sparse warnings

drivers/net/ethernet/ti/davinci_cpdma.c:182:29: warning: incorrect type in assignment (different address spaces)
drivers/net/ethernet/ti/davinci_cpdma.c:182:29:    expected void [noderef] <asn:2>*iomap
drivers/net/ethernet/ti/davinci_cpdma.c:182:29:    got void *cpumap
drivers/net/ethernet/ti/davinci_cpdma.c:953:27: warning: symbol 'controls' was not declared. Should it be static?
drivers/net/ethernet/ti/cpsw.c:451:6: warning: symbol 'cpsw_tx_handler' was not declared. Should it be static?
drivers/net/ethernet/ti/cpsw.c:468:6: warning: symbol 'cpsw_rx_handler' was not declared. Should it be static?
drivers/net/ethernet/ti/cpsw_ale.c:151:5: warning: symbol 'cpsw_ale_match_addr' was not declared. Should it be static?
drivers/net/ethernet/ti/cpsw_ale.c:172:5: warning: symbol 'cpsw_ale_match_vlan' was not declared. Should it be static?

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c          |    4 ++--
 drivers/net/ethernet/ti/cpsw_ale.c      |    4 ++--
 drivers/net/ethernet/ti/davinci_cpdma.c |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 7aebc0c..f4be85b 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -448,7 +448,7 @@ static void cpsw_intr_disable(struct cpsw_priv *priv)
 	return;
 }
 
-void cpsw_tx_handler(void *token, int len, int status)
+static void cpsw_tx_handler(void *token, int len, int status)
 {
 	struct sk_buff		*skb = token;
 	struct net_device	*ndev = skb->dev;
@@ -465,7 +465,7 @@ void cpsw_tx_handler(void *token, int len, int status)
 	dev_kfree_skb_any(skb);
 }
 
-void cpsw_rx_handler(void *token, int len, int status)
+static void cpsw_rx_handler(void *token, int len, int status)
 {
 	struct sk_buff		*skb = token;
 	struct net_device	*ndev = skb->dev;
diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index 7fa60d6..79f0b79 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -148,7 +148,7 @@ static int cpsw_ale_write(struct cpsw_ale *ale, int idx, u32 *ale_entry)
 	return idx;
 }
 
-int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr, u16 vid)
+static int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr, u16 vid)
 {
 	u32 ale_entry[ALE_ENTRY_WORDS];
 	int type, idx;
@@ -169,7 +169,7 @@ int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr, u16 vid)
 	return -ENOENT;
 }
 
-int cpsw_ale_match_vlan(struct cpsw_ale *ale, u16 vid)
+static int cpsw_ale_match_vlan(struct cpsw_ale *ale, u16 vid)
 {
 	u32 ale_entry[ALE_ENTRY_WORDS];
 	int type, idx;
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index ee13dc7..a6f5de9 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -179,7 +179,7 @@ cpdma_desc_pool_create(struct device *dev, u32 phys, u32 hw_addr,
 	} else {
 		pool->cpumap = dma_alloc_coherent(dev, size, &pool->phys,
 						  GFP_KERNEL);
-		pool->iomap = pool->cpumap;
+		pool->iomap = (void __iomem *) pool->cpumap;
 		pool->hw_addr = pool->phys;
 	}
 
@@ -950,7 +950,7 @@ struct cpdma_control_info {
 #define ACCESS_RW	(ACCESS_RO | ACCESS_WO)
 };
 
-struct cpdma_control_info controls[] = {
+static struct cpdma_control_info controls[] = {
 	[CPDMA_CMD_IDLE]	  = {CPDMA_DMACONTROL,	3,  1,      ACCESS_WO},
 	[CPDMA_COPY_ERROR_FRAMES] = {CPDMA_DMACONTROL,	4,  1,      ACCESS_RW},
 	[CPDMA_RX_OFF_LEN_UPDATE] = {CPDMA_DMACONTROL,	2,  1,      ACCESS_RW},
-- 
1.7.9.5

