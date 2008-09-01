From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 42/52] sfc: Fix memory BAR release call on error path
Date: Mon, 1 Sep 2008 12:49:15 +0100
Message-ID: <20080901114914.GI7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:36442 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759188AbYIALtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:49:17 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Match pci_request_region() with pci_release_region(), not
release_mem_region().

From: Steve Hodgson <shodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 4b26ad0..c295ea6 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -780,7 +780,7 @@ static int efx_init_io(struct efx_nic *efx)
 	return 0;
 
  fail4:
-	release_mem_region(efx->membase_phys, efx->type->mem_map_size);
+	pci_release_region(efx->pci_dev, efx->type->mem_bar);
  fail3:
 	efx->membase_phys = 0;
  fail2:
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

