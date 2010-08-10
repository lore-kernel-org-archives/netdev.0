From: sjur.brandeland@stericsson.com
Subject: [PATCH 2/2] caif-spi: Bugfix SPI_DATA_POS settings were inverted.
Date: Tue, 10 Aug 2010 19:36:47 +0200
Message-ID: <1281461807-17408-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1281461807-17408-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: sjurbren@gmail.com, netdev@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:37416 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932515Ab0HJShs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 14:37:48 -0400
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L6Y00FGS69EOW90@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Tue, 10 Aug 2010 19:36:50 +0200 (CEST)
Received: from localhost.localdomain ([84.49.77.68]) by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L6Y00LT669DLCT0@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Tue, 10 Aug 2010 19:36:50 +0200 (CEST)
In-reply-to: <1281461807-17408-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

The setting of SPI_DATA_POS depending on CONFIG_CAIF_SPI_SYNC
where inverted.


Change-Id: I4886d1d69cc50557f516e05c40f649fed55384a2

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_spi_slave.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/caif/caif_spi_slave.c b/drivers/net/caif/caif_spi_slave.c
index 077ccf8..2111dbf 100644
--- a/drivers/net/caif/caif_spi_slave.c
+++ b/drivers/net/caif/caif_spi_slave.c
@@ -22,13 +22,13 @@
 #include <net/caif/caif_spi.h>
 
 #ifndef CONFIG_CAIF_SPI_SYNC
-#define SPI_DATA_POS SPI_CMD_SZ
+#define SPI_DATA_POS 0
 static inline int forward_to_spi_cmd(struct cfspi *cfspi)
 {
 	return cfspi->rx_cpck_len;
 }
 #else
-#define SPI_DATA_POS 0
+#define SPI_DATA_POS SPI_CMD_SZ
 static inline int forward_to_spi_cmd(struct cfspi *cfspi)
 {
 	return 0;
-- 
1.6.3.3

