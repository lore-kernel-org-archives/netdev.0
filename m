From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH v1 2/4] soc: ti: knav_dma: rename pad in struct knav_dma_desc to sw_data
Date: Thu, 18 Feb 2016 14:46:15 -0500
Message-ID: <1455824777-15571-2-git-send-email-m-karicheri2@ti.com>
References: <1455824777-15571-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455824777-15571-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename the pad to sw_data as per description of this field in the hardware
spec(refer sprugr9 from www.ti.com). Latest version of the document is
at http://www.ti.com/lit/ug/sprugr9h/sprugr9h.pdf and section 3.1
Host Packet Descriptor describes this field.

Also define and use a constant for the size of sw_data field similar to
other fields in the struct for desc and document the sw_data field
in the header. As the sw_data is not touched by hw, it's type can be
changed to u32.

Cc: Wingman Kwok <w-kwok2@ti.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
CC: Arnd Bergmann <arnd@arndb.de>
CC: Grygorii Strashko <grygorii.strashko@ti.com>
CC: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 new patch based on discussion at https://patchwork.ozlabs.org/patch/580860/
 include/linux/soc/ti/knav_dma.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/soc/ti/knav_dma.h b/include/linux/soc/ti/knav_dma.h
index 343c13a..35cb926 100644
--- a/include/linux/soc/ti/knav_dma.h
+++ b/include/linux/soc/ti/knav_dma.h
@@ -44,6 +44,7 @@
 
 #define KNAV_DMA_NUM_EPIB_WORDS			4
 #define KNAV_DMA_NUM_PS_WORDS			16
+#define KNAV_DMA_NUM_SW_DATA_WORDS		4
 #define KNAV_DMA_FDQ_PER_CHAN			4
 
 /* Tx channel scheduling priority */
@@ -142,6 +143,7 @@ struct knav_dma_cfg {
  * @orig_buff:			buff pointer since 'buff' can be overwritten
  * @epib:			Extended packet info block
  * @psdata:			Protocol specific
+ * @sw_data:			Software private data not touched by h/w
  */
 struct knav_dma_desc {
 	__le32	desc_info;
@@ -154,7 +156,7 @@ struct knav_dma_desc {
 	__le32	orig_buff;
 	__le32	epib[KNAV_DMA_NUM_EPIB_WORDS];
 	__le32	psdata[KNAV_DMA_NUM_PS_WORDS];
-	__le32	pad[4];
+	u32	sw_data[KNAV_DMA_NUM_SW_DATA_WORDS];
 } ____cacheline_aligned;
 
 #if IS_ENABLED(CONFIG_KEYSTONE_NAVIGATOR_DMA)
-- 
1.9.1
