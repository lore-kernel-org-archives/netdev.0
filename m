From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH 1/2] net: mvpp2: don't bring up on MAC address set
Date: Wed,  9 Nov 2016 14:56:33 +0200
Message-ID: <ff17831771f3575f351c134703d3f153485b01c0.1478696194.git.baruch@tkos.co.il>
Cc: netdev@vger.kernel.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Baruch Siach <baruch@tkos.co.il>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:53459 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752509AbcKIM4v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 07:56:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current .ndo_set_mac_address implementation brings up the interface when revert
to original address after failure succeeds. Fix this.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
Untested; I don't have the hardware.
---
 drivers/net/ethernet/marvell/mvpp2.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 60227a3452a4..e427b4706726 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5686,9 +5686,8 @@ static int mvpp2_set_mac_address(struct net_device *dev, void *p)
 		if (!err)
 			return 0;
 		/* Reconfigure parser to accept the original MAC address */
-		err = mvpp2_prs_update_mac_da(dev, dev->dev_addr);
-		if (err)
-			goto error;
+		mvpp2_prs_update_mac_da(dev, dev->dev_addr);
+		goto error;
 	}
 
 	mvpp2_stop_dev(port);
@@ -5698,9 +5697,8 @@ static int mvpp2_set_mac_address(struct net_device *dev, void *p)
 		goto out_start;
 
 	/* Reconfigure parser accept the original MAC address */
-	err = mvpp2_prs_update_mac_da(dev, dev->dev_addr);
-	if (err)
-		goto error;
+	mvpp2_prs_update_mac_da(dev, dev->dev_addr);
+	goto error;
 out_start:
 	mvpp2_start_dev(port);
 	mvpp2_egress_enable(port);
-- 
2.10.2
