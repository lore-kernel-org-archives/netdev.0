From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] fsl_pq_mdio: Revive UCC MDIO support
Date: Tue, 31 Mar 2009 22:33:52 +0400
Message-ID: <20090331183352.GA4474@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	Andy Fleming <afleming@freescale.com>,
	Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:2821 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753246AbZCaSdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 14:33:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1577ecef766650a57fceb171acee2b13cbfaf1d3 ("netdev: Merge UCC
and gianfar MDIO bus drivers") introduced a regression so that UCC
MDIO buses no longer work.

This is because fsl_pq_mdio driver wrongly masks all non-TBI PHYs
for !fsl,gianfar-mdio buses, while it should do that only for
fsl,gianfar-tbi buses.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/fsl_pq_mdio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index b3079a5..d9e1ecf 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -387,7 +387,7 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 	 * The TBIPHY-only buses will find PHYs at every address,
 	 * so we mask them all but the TBI
 	 */
-	if (!of_device_is_compatible(np, "fsl,gianfar-mdio"))
+	if (of_device_is_compatible(np, "fsl,gianfar-tbi"))
 		new_bus->phy_mask = ~(1 << tbiaddr);
 
 	err = mdiobus_register(new_bus);
-- 
1.5.6.5
