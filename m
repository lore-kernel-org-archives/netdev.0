From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 31/33] sfc: Use kzalloc() to ensure struct efx_spi_device is fully initialised
Date: Fri, 12 Dec 2008 13:00:30 +0000
Message-ID: <20081212130029.GE10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:59805 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758063AbYLLNAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 08:00:31 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the mtd field is not initialised early enough.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 63414ce..e09a01d 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2701,7 +2701,7 @@ static int falcon_spi_device_init(struct efx_nic *efx,
 	struct efx_spi_device *spi_device;
 
 	if (device_type != 0) {
-		spi_device = kmalloc(sizeof(*spi_device), GFP_KERNEL);
+		spi_device = kzalloc(sizeof(*spi_device), GFP_KERNEL);
 		if (!spi_device)
 			return -ENOMEM;
 		spi_device->device_id = device_id;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
