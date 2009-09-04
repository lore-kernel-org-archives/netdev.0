From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 13/29] ioat1: kill unused unmap parameters
Date: Thu, 03 Sep 2009 19:31:36 -0700
Message-ID: <20090904023136.32667.56906.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The unified ioat1/ioat2 ioat_dma_unmap() implementation derives the
source and dest addresses from the unmap descriptor.  There is no longer
a need to track this information in struct ioat_desc_sw.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c |    2 --
 drivers/dma/ioat/dma.h |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index 64b4d75..696d4de 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -648,8 +648,6 @@ ioat1_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 
 	desc->txd.flags = flags;
 	desc->tx_cnt = tx_cnt;
-	desc->src = dma_src;
-	desc->dst = dma_dest;
 	desc->len = total_len;
 	list_splice(&chain, &desc->txd.tx_list);
 	hw->ctl_f.int_en = !!(flags & DMA_PREP_INTERRUPT);
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index 84065df..fa15e77 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -179,8 +179,6 @@ struct ioat_desc_sw {
 	struct list_head node;
 	int tx_cnt;
 	size_t len;
-	dma_addr_t src;
-	dma_addr_t dst;
 	struct dma_async_tx_descriptor txd;
 };
 

