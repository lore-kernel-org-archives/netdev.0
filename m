From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH] fs_enet: Fix a memory leak in fs_enet_mdio_probe
Date: Fri, 2 May 2008 13:31:18 -0500
Message-ID: <20080502183118.GA2918@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:51993 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757088AbYEBSbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 14:31:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are more memory leaks in the !PPC_CPM_NEW_BINDING case, but that code
will disappear soon along with arch/ppc.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/fs_enet/mii-fec.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index ba75efc..f0014cf 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -194,7 +194,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 
 	ret = of_address_to_resource(ofdev->node, 0, &res);
 	if (ret)
-		return ret;
+		goto out_res;
 
 	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", res.start);
 
@@ -236,6 +236,7 @@ out_free_irqs:
 	kfree(new_bus->irq);
 out_unmap_regs:
 	iounmap(fec->fecp);
+out_res:
 out_fec:
 	kfree(fec);
 out_mii:
-- 
1.5.4.4
