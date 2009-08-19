From: Sudhakar Rajashekhara <sudhakar.raj@ti.com>
Subject: [PATCH] TI DaVinci EMAC: delay DaVinci EMAC initialization
Date: Wed, 19 Aug 2009 16:39:55 -0400
Message-ID: <1250714395-9588-1-git-send-email-sudhakar.raj@ti.com>
Cc: davem@davemloft.net, chaithrika@ti.com, anantgole@ti.com,
	davinci-linux-open-source@linux.davincidsp.com,
	Sudhakar Rajashekhara <sudhakar.raj@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:50651 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbZHSLNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 07:13:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On TI's DA850/OMAP-L138 EVM, MAC address is stored in SPI
flash which is accessed using MTD interface.

This patch delays the initialization of DaVinci EMAC driver
by changing module_init to late_initcall. This helps SPI and
MTD drivers to get initialized before EMAC thereby enabling
EMAC driver to read the MAC address while booting and use it.

Tested with NFS on DM644x, DM6467, DA830/OMAP-L137 and
DA850/OMAP-L138 EVMs.

Signed-off-by: Sudhakar Rajashekhara <sudhakar.raj@ti.com>
Reviewed-by: Chaithrika U S <chaithrika@ti.com>
---
 drivers/net/davinci_emac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 12fd446..5e6652b 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2817,7 +2817,7 @@ static int __init davinci_emac_init(void)
 {
 	return platform_driver_register(&davinci_emac_driver);
 }
-module_init(davinci_emac_init);
+late_initcall(davinci_emac_init);
 
 /**
  * davinci_emac_exit: EMAC driver module exit
-- 
1.5.6

