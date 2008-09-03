From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] sfc: Fix type of FALCON_SPI_MAX_LEN
Date: Wed, 3 Sep 2008 15:37:01 +0100
Message-ID: <20080903143700.GA7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:55843 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755869AbYICOhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 10:37:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FALCON_SPI_MAX_LEN has type size_t while other SPI lengths have type
unsigned int.  This results in warnings from min() on 64-bit
architectures where they are different.  Add a cast to make it match.

From: Steve Hodgson <shodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index d30c938..31ed1f4 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1605,7 +1605,7 @@ void falcon_fini_interrupt(struct efx_nic *efx)
  **************************************************************************
  */
 
-#define FALCON_SPI_MAX_LEN sizeof(efx_oword_t)
+#define FALCON_SPI_MAX_LEN ((unsigned) sizeof(efx_oword_t))
 
 /* Wait for SPI command completion */
 static int falcon_spi_wait(struct efx_nic *efx)
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
