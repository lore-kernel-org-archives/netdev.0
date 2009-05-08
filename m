From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] DMA: mark DMA_nBITS_MASK as deprecated
Date: Fri,  8 May 2009 10:00:38 +0200
Message-ID: <1241769638-27301-1-git-send-email-jirislaby@gmail.com>
References: <20090507111846.GI28398@elte.hu>
Cc: yanghy@cn.fujitsu.com, akpm@linux-foundation.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wellnetcz.com ([212.24.148.102]:36920 "EHLO
	smtp.wellnetcz.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbZEHICG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 04:02:06 -0400
In-Reply-To: <20090507111846.GI28398@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar <mingo@elte.hu> wrote:
> Can you see a way to emit build warnings? If yes then that might be 
> a better solution instead of breaking in-the-pipeline code.

What about this:
--

Mark them deprecated so that 3rd party vendors get notified about that
before their modules break by removing those macros later.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
---
 include/linux/dma-mapping.h |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 8083b6a..6bf3339 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -63,24 +63,26 @@ struct dma_map_ops {
 
 #define DMA_BIT_MASK(n)	(((n) == 64) ? ~0ULL : ((1ULL<<(n))-1))
 
+typedef u64 DMA_DEPRECATED __deprecated;
+
 /*
  * NOTE: do not use the below macros in new code and do not add new definitions
  * here.
  *
  * Instead, just open-code DMA_BIT_MASK(n) within your driver
  */
-#define DMA_64BIT_MASK	DMA_BIT_MASK(64)
-#define DMA_48BIT_MASK	DMA_BIT_MASK(48)
-#define DMA_47BIT_MASK	DMA_BIT_MASK(47)
-#define DMA_40BIT_MASK	DMA_BIT_MASK(40)
-#define DMA_39BIT_MASK	DMA_BIT_MASK(39)
-#define DMA_35BIT_MASK	DMA_BIT_MASK(35)
-#define DMA_32BIT_MASK	DMA_BIT_MASK(32)
-#define DMA_31BIT_MASK	DMA_BIT_MASK(31)
-#define DMA_30BIT_MASK	DMA_BIT_MASK(30)
-#define DMA_29BIT_MASK	DMA_BIT_MASK(29)
-#define DMA_28BIT_MASK	DMA_BIT_MASK(28)
-#define DMA_24BIT_MASK	DMA_BIT_MASK(24)
+#define DMA_64BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(64)
+#define DMA_48BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(48)
+#define DMA_47BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(47)
+#define DMA_40BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(40)
+#define DMA_39BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(39)
+#define DMA_35BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(35)
+#define DMA_32BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(32)
+#define DMA_31BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(31)
+#define DMA_30BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(30)
+#define DMA_29BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(29)
+#define DMA_28BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(28)
+#define DMA_24BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(24)
 
 #define DMA_MASK_NONE	0x0ULL
 
-- 
1.6.2.4

