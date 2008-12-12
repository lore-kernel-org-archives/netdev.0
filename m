From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 02/33] sfc: Change SPI lengths to type size_t
Date: Fri, 12 Dec 2008 12:48:51 +0000
Message-ID: <20081212124851.GB10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:48498 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756506AbYLLMsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:48:54 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on a patch by Andrew Morton.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 71e0bed..271cbf8 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1605,7 +1605,7 @@ void falcon_fini_interrupt(struct efx_nic *efx)
  **************************************************************************
  */
 
-#define FALCON_SPI_MAX_LEN ((unsigned) sizeof(efx_oword_t))
+#define FALCON_SPI_MAX_LEN sizeof(efx_oword_t)
 
 /* Wait for SPI command completion */
 static int falcon_spi_wait(struct efx_nic *efx)
@@ -1630,7 +1630,7 @@ static int falcon_spi_wait(struct efx_nic *efx)
 
 int falcon_spi_cmd(const struct efx_spi_device *spi,
 		   unsigned int command, int address,
-		   const void *in, void *out, unsigned int len)
+		   const void *in, void *out, size_t len)
 {
 	struct efx_nic *efx = spi->efx;
 	bool addressed = (address >= 0);
@@ -1686,8 +1686,8 @@ int falcon_spi_cmd(const struct efx_spi_device *spi,
 	return 0;
 }
 
-static unsigned int
-falcon_spi_write_limit(const struct efx_spi_device *spi, unsigned int start)
+static size_t
+falcon_spi_write_limit(const struct efx_spi_device *spi, size_t start)
 {
 	return min(FALCON_SPI_MAX_LEN,
 		   (spi->block_size - (start & (spi->block_size - 1))));
@@ -1725,12 +1725,12 @@ int falcon_spi_fast_wait(const struct efx_spi_device *spi)
 int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
 		    size_t len, size_t *retlen, u8 *buffer)
 {
-	unsigned int command, block_len, pos = 0;
+	size_t block_len, pos = 0;
+	unsigned int command;
 	int rc = 0;
 
 	while (pos < len) {
-		block_len = min((unsigned int)len - pos,
-				FALCON_SPI_MAX_LEN);
+		block_len = min(len - pos, FALCON_SPI_MAX_LEN);
 
 		command = efx_spi_munge_command(spi, SPI_READ, start + pos);
 		rc = falcon_spi_cmd(spi, command, start + pos, NULL,
@@ -1756,7 +1756,8 @@ int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
 		     size_t len, size_t *retlen, const u8 *buffer)
 {
 	u8 verify_buffer[FALCON_SPI_MAX_LEN];
-	unsigned int command, block_len, pos = 0;
+	size_t block_len, pos = 0;
+	unsigned int command;
 	int rc = 0;
 
 	while (pos < len) {
@@ -1764,7 +1765,7 @@ int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
 		if (rc)
 			break;
 
-		block_len = min((unsigned int)len - pos,
+		block_len = min(len - pos,
 				falcon_spi_write_limit(spi, start + pos));
 		command = efx_spi_munge_command(spi, SPI_WRITE, start + pos);
 		rc = falcon_spi_cmd(spi, command, start + pos,
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
