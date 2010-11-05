From: Joe Perches <joe@perches.com>
Subject: [PATCH 28/49] drivers/net/pch_gbe: Use vzalloc
Date: Thu,  4 Nov 2010 20:07:52 -0700
Message-ID: <c38e12c7c652bb3da28566ba5cb78d0fe68f5d20.1288925425.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 472056b..afb7506 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -1523,12 +1523,11 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
 	int desNo;
 
 	size = (int)sizeof(struct pch_gbe_buffer) * tx_ring->count;
-	tx_ring->buffer_info = vmalloc(size);
+	tx_ring->buffer_info = vzalloc(size);
 	if (!tx_ring->buffer_info) {
 		pr_err("Unable to allocate memory for the buffer infomation\n");
 		return -ENOMEM;
 	}
-	memset(tx_ring->buffer_info, 0, size);
 
 	tx_ring->size = tx_ring->count * (int)sizeof(struct pch_gbe_tx_desc);
 
@@ -1573,12 +1572,11 @@ int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
 	int desNo;
 
 	size = (int)sizeof(struct pch_gbe_buffer) * rx_ring->count;
-	rx_ring->buffer_info = vmalloc(size);
+	rx_ring->buffer_info = vzalloc(size);
 	if (!rx_ring->buffer_info) {
 		pr_err("Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(rx_ring->buffer_info, 0, size);
 	rx_ring->size = rx_ring->count * (int)sizeof(struct pch_gbe_rx_desc);
 	rx_ring->desc =	dma_alloc_coherent(&pdev->dev, rx_ring->size,
 					   &rx_ring->dma, GFP_KERNEL);
-- 
1.7.3.1.g432b3.dirty
