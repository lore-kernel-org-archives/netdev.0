From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/11] sound/hal2: switch to dma_alloc_attrs
Date: Fri, 16 Jun 2017 09:17:09 +0200
Message-ID: <20170616071716.17321-5-hch@lst.de>
References: <20170616071716.17321-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
        netdev@vger.kernel.org, linux-metag@vger.kernel.org,
        nios2-dev@lists.rocketboards.org, linux-fbdev@vger.kernel.org,
        alsa-devel@alsa-project.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170616071716.17321-1-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dma_alloc_attrs directly instead of the dma_alloc_noncoherent wrapper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 sound/mips/hal2.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/sound/mips/hal2.c b/sound/mips/hal2.c
index 00fc9241d266..17a78a93e885 100644
--- a/sound/mips/hal2.c
+++ b/sound/mips/hal2.c
@@ -461,15 +461,15 @@ static int hal2_alloc_dmabuf(struct hal2_codec *codec)
 	int count = H2_BUF_SIZE / H2_BLOCK_SIZE;
 	int i;
 
-	codec->buffer = dma_alloc_noncoherent(NULL, H2_BUF_SIZE,
-					      &buffer_dma, GFP_KERNEL);
+	codec->buffer = dma_alloc_attrs(NULL, H2_BUF_SIZE, &buffer_dma,
+					GFP_KERNEL, DMA_ATTR_NON_CONSISTENT);
 	if (!codec->buffer)
 		return -ENOMEM;
-	desc = dma_alloc_noncoherent(NULL, count * sizeof(struct hal2_desc),
-				     &desc_dma, GFP_KERNEL);
+	desc = dma_alloc_attrs(NULL, count * sizeof(struct hal2_desc),
+			       &desc_dma, GFP_KERNEL, DMA_ATTR_NON_CONSISTENT);
 	if (!desc) {
-		dma_free_noncoherent(NULL, H2_BUF_SIZE,
-				     codec->buffer, buffer_dma);
+		dma_free_attrs(NULL, H2_BUF_SIZE, codec->buffer, buffer_dma,
+			       DMA_ATTR_NON_CONSISTENT);
 		return -ENOMEM;
 	}
 	codec->buffer_dma = buffer_dma;
@@ -490,10 +490,10 @@ static int hal2_alloc_dmabuf(struct hal2_codec *codec)
 
 static void hal2_free_dmabuf(struct hal2_codec *codec)
 {
-	dma_free_noncoherent(NULL, codec->desc_count * sizeof(struct hal2_desc),
-			     codec->desc, codec->desc_dma);
-	dma_free_noncoherent(NULL, H2_BUF_SIZE, codec->buffer,
-			     codec->buffer_dma);
+	dma_free_attrs(NULL, codec->desc_count * sizeof(struct hal2_desc),
+		       codec->desc, codec->desc_dma, DMA_ATTR_NON_CONSISTENT);
+	dma_free_attrs(NULL, H2_BUF_SIZE, codec->buffer, codec->buffer_dma,
+		       DMA_ATTR_NON_CONSISTENT);
 }
 
 static struct snd_pcm_hardware hal2_pcm_hw = {
-- 
2.11.0
