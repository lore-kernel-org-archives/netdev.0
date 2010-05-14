From: Anton Vorontsov <avorontsov@mvista.com>
Subject: [PATCH] fsl_pq_mdio: Fix mdiobus allocation handling
Date: Fri, 14 May 2010 18:27:30 +0400
Message-ID: <20100514142730.GA13137@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:34235 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752291Ab0ENO1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 10:27:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver could return success code even if mdiobus_alloc() failed.
This patch fixes the issue.

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 drivers/net/fsl_pq_mdio.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index 3acac5f..ff028f5 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -277,15 +277,17 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 	int tbiaddr = -1;
 	const u32 *addrp;
 	u64 addr = 0, size = 0;
-	int err = 0;
+	int err;
 
 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
 	if (!priv)
 		return -ENOMEM;
 
 	new_bus = mdiobus_alloc();
-	if (NULL == new_bus)
+	if (!new_bus) {
+		err = -ENOMEM;
 		goto err_free_priv;
+	}
 
 	new_bus->name = "Freescale PowerQUICC MII Bus",
 	new_bus->read = &fsl_pq_mdio_read,
-- 
1.7.0.5

