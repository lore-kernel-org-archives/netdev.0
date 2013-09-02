From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] sfc: check for allocation failure
Date: Mon, 2 Sep 2013 12:04:42 +0300
Message-ID: <20130902082828.GA30037@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21395 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758053Ab3IBJEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 05:04:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It upsets static analyzers when we don't check for allocation failure.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
index ba6c87a..aac6897 100644
--- a/drivers/net/ethernet/sfc/mtd.c
+++ b/drivers/net/ethernet/sfc/mtd.c
@@ -384,6 +384,8 @@ static int falcon_mtd_probe(struct efx_nic *efx)
 
 	/* Allocate space for maximum number of partitions */
 	parts = kcalloc(2, sizeof(*parts), GFP_KERNEL);
+	if (!parts)
+		return -ENOMEM;
 	n_parts = 0;
 
 	spi = &nic_data->spi_flash;
