From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 6/7] sfc: Expose FPGA bitfile partition through MTD
Date: Wed, 18 Jul 2012 19:22:17 +0100
Message-ID: <1342635737.2617.58.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Andrew Jackson <ajackson@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51842 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755317Ab2GRSWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:22:21 -0400
In-Reply-To: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mtd.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
index 8f4604d..08f825b 100644
--- a/drivers/net/ethernet/sfc/mtd.c
+++ b/drivers/net/ethernet/sfc/mtd.c
@@ -585,6 +585,7 @@ static const struct siena_nvram_type_info siena_nvram_types[] = {
 	[MC_CMD_NVRAM_TYPE_EXP_ROM_CFG_PORT1]	= { 1, "sfc_exp_rom_cfg" },
 	[MC_CMD_NVRAM_TYPE_PHY_PORT0]		= { 0, "sfc_phy_fw" },
 	[MC_CMD_NVRAM_TYPE_PHY_PORT1]		= { 1, "sfc_phy_fw" },
+	[MC_CMD_NVRAM_TYPE_FPGA]		= { 0, "sfc_fpga" },
 };
 
 static int siena_mtd_probe_partition(struct efx_nic *efx,
@@ -598,7 +599,8 @@ static int siena_mtd_probe_partition(struct efx_nic *efx,
 	bool protected;
 	int rc;
 
-	if (type >= ARRAY_SIZE(siena_nvram_types))
+	if (type >= ARRAY_SIZE(siena_nvram_types) ||
+	    siena_nvram_types[type].name == NULL)
 		return -ENODEV;
 
 	info = &siena_nvram_types[type];
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
