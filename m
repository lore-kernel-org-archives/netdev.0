From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [PATCH 1/3] wlcore: fix frame size overflow warning in wl12xx_spi_raw_write
Date: Thu, 12 Sep 2013 17:32:21 +0200
Message-ID: <1378999943-1968-2-git-send-email-murzin.v@gmail.com>
References: <1378999943-1968-1-git-send-email-murzin.v@gmail.com>
Cc: coelho@ti.com, linville@tuxdriver.com,
	Vladimir Murzin <murzin.v@gmail.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:55994 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187Ab3ILPdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 11:33:39 -0400
In-Reply-To: <1378999943-1968-1-git-send-email-murzin.v@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While cross-building for PPC64 I've got

drivers/net/wireless/ti/wlcore/spi.c: In function
'wl12xx_spi_raw_write': drivers/net/wireless/ti/wlcore/spi.c:317:1:
warning: the frame size of 9712 bytes is larger than 2048 bytes
[-Wframe-larger-than=]

WSPI_MAX_NUM_OF_CHUNKS depends on SPI_AGGR_BUFFER_SIZE which in turn
is based on PAGE_SIZE. For most systems PAGE_SIZE is stands for 4K,
but it may vary - in my case PAGE_SIZE is 64K.

Fix calculation by using 4K explicitly.

Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
---
 drivers/net/wireless/ti/wlcore/spi.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index 1b0cd98..8dce028 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -70,7 +70,8 @@
  * only support SPI for 12xx - this code should be reworked when 18xx
  * support is introduced
  */
-#define SPI_AGGR_BUFFER_SIZE (4 * PAGE_SIZE)
+#define SPI_PAGE_SIZE	4096
+#define SPI_AGGR_BUFFER_SIZE (4 * SPI_PAGE_SIZE)
 
 #define WSPI_MAX_NUM_OF_CHUNKS (SPI_AGGR_BUFFER_SIZE / WSPI_MAX_CHUNK_SIZE)
 
-- 
1.7.10.4
