From: Nikita Kiryanov <nikita@compulab.co.il>
Subject: [PATCH 2/4] dm9000: take phy out of reset during init
Date: Wed, 16 Oct 2013 11:41:32 +0300
Message-ID: <1381912894-4780-3-git-send-email-nikita@compulab.co.il>
References: <1381912894-4780-1-git-send-email-nikita@compulab.co.il>
Cc: Nikita Kiryanov <nikita@compulab.co.il>,
	"David S. Miller" <davem@davemloft.net>,
	Jingoo Han <jg1.han@samsung.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Igor Grinberg <grinberg@compulab.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from softlayer.compulab.co.il ([50.23.254.55]:48034 "EHLO
	compulab.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753674Ab3JPImK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 04:42:10 -0400
In-Reply-To: <1381912894-4780-1-git-send-email-nikita@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take the phy out of reset explicitly during system resume to avoid
losing network connectivity.

Cc: David S. Miller <davem@davemloft.net>
Cc: Jingoo Han <jg1.han@samsung.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Nikita Kiryanov <nikita@compulab.co.il>
Signed-off-by: Igor Grinberg <grinberg@compulab.co.il>
---
 drivers/net/ethernet/davicom/dm9000.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 912983b..3f650ce 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -890,6 +890,7 @@ dm9000_init_dm9000(struct net_device *dev)
 			(dev->features & NETIF_F_RXCSUM) ? RCSR_CSUM : 0);
 
 	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
+	iow(db, DM9000_GPR, 0);
 
 	/* If we are dealing with DM9000B, some extra steps are required: a
 	 * manual phy reset, and setting init params.
-- 
1.8.1.2
