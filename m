From: akpm@linux-foundation.org
Subject: [patch 21/21] drivers/net/sfc/falcon.c: fix min() warnings
Date: Mon, 22 Sep 2008 14:52:29 -0700
Message-ID: <200809222152.m8MLqTQ9032000@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	bhutchings@solarflare.com, jgarzik@redhat.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59063 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753462AbYIVVyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:54:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

drivers/net/sfc/falcon.c: In function 'falcon_spi_write_limit':
drivers/net/sfc/falcon.c:1679: warning: comparison of distinct pointer types lacks a cast
drivers/net/sfc/falcon.c: In function 'falcon_spi_read':
drivers/net/sfc/falcon.c:1720: warning: comparison of distinct pointer types lacks a cast

Driver seems rather confused about types.  Try to help it.

Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Jeff Garzik <jgarzik@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/sfc/falcon.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff -puN drivers/net/sfc/falcon.c~drivers-net-sfc-falconc-fix-min-warnings drivers/net/sfc/falcon.c
--- a/drivers/net/sfc/falcon.c~drivers-net-sfc-falconc-fix-min-warnings
+++ a/drivers/net/sfc/falcon.c
@@ -1673,8 +1673,8 @@ static int falcon_spi_cmd(const struct e
 	return 0;
 }
 
-static unsigned int
-falcon_spi_write_limit(const struct efx_spi_device *spi, unsigned int start)
+static size_t
+falcon_spi_write_limit(const struct efx_spi_device *spi, size_t start)
 {
 	return min(FALCON_SPI_MAX_LEN,
 		   (spi->block_size - (start & (spi->block_size - 1))));
@@ -1717,8 +1717,7 @@ int falcon_spi_read(const struct efx_spi
 	int rc = 0;
 
 	while (pos < len) {
-		block_len = min((unsigned int)len - pos,
-				FALCON_SPI_MAX_LEN);
+		block_len = min(len - pos, FALCON_SPI_MAX_LEN);
 
 		command = efx_spi_munge_command(spi, SPI_READ, start + pos);
 		rc = falcon_spi_cmd(spi, command, start + pos, NULL,
@@ -1752,7 +1751,7 @@ int falcon_spi_write(const struct efx_sp
 		if (rc)
 			break;
 
-		block_len = min((unsigned int)len - pos,
+		block_len = min(len - pos,
 				falcon_spi_write_limit(spi, start + pos));
 		command = efx_spi_munge_command(spi, SPI_WRITE, start + pos);
 		rc = falcon_spi_cmd(spi, command, start + pos,
_
