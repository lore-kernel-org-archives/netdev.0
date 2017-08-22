From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v12 7/8] wireless: ipw2200: Replace PCI pool old API
Date: Tue, 22 Aug 2017 13:47:00 +0200
Message-ID: <20170822114701.14907-8-romain.perier@collabora.com>
References: <20170822114701.14907-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Romain Perier <romain.perier@collabora.com>
To: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170822114701.14907-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 drivers/net/wireless/intel/ipw2x00/ipw2200.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2200.c b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
index c311b1a994c1..c57c567add4d 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
@@ -3209,7 +3209,7 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
 	struct fw_chunk *chunk;
 	int total_nr = 0;
 	int i;
-	struct pci_pool *pool;
+	struct dma_pool *pool;
 	void **virts;
 	dma_addr_t *phys;
 
@@ -3226,9 +3226,10 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
 		kfree(virts);
 		return -ENOMEM;
 	}
-	pool = pci_pool_create("ipw2200", priv->pci_dev, CB_MAX_LENGTH, 0, 0);
+	pool = dma_pool_create("ipw2200", &priv->pci_dev->dev, CB_MAX_LENGTH, 0,
+			       0);
 	if (!pool) {
-		IPW_ERROR("pci_pool_create failed\n");
+		IPW_ERROR("dma_pool_create failed\n");
 		kfree(phys);
 		kfree(virts);
 		return -ENOMEM;
@@ -3253,7 +3254,7 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
 
 		nr = (chunk_len + CB_MAX_LENGTH - 1) / CB_MAX_LENGTH;
 		for (i = 0; i < nr; i++) {
-			virts[total_nr] = pci_pool_alloc(pool, GFP_KERNEL,
+			virts[total_nr] = dma_pool_alloc(pool, GFP_KERNEL,
 							 &phys[total_nr]);
 			if (!virts[total_nr]) {
 				ret = -ENOMEM;
@@ -3297,9 +3298,9 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
 	}
  out:
 	for (i = 0; i < total_nr; i++)
-		pci_pool_free(pool, virts[i], phys[i]);
+		dma_pool_free(pool, virts[i], phys[i]);
 
-	pci_pool_destroy(pool);
+	dma_pool_destroy(pool);
 	kfree(phys);
 	kfree(virts);
 
-- 
2.11.0
