From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] sfc: check for allocation failure
Date: Wed, 4 Sep 2013 18:07:27 +0300
Message-ID: <20130904150727.GA32327@elgon.mountain>
References: <20130903.224939.866623192858217581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130903.224939.866623192858217581.davem@davemloft.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It upsets static analyzers when we don't check for allocation failure.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: rebased on latest linux-next

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 38d179c..75799f8 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -894,6 +894,8 @@ static int falcon_mtd_probe(struct efx_nic *efx)
 
 	/* Allocate space for maximum number of partitions */
 	parts = kcalloc(2, sizeof(*parts), GFP_KERNEL);
+	if (!parts)
+		return -ENOMEM;
 	n_parts = 0;
 
 	spi = &nic_data->spi_flash;
