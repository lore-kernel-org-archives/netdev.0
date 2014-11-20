From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/1] IBM-EMAC: Deletion of unnecessary checks before the function
 call "of_dev_put"
Date: Thu, 20 Nov 2014 14:28:25 +0100
Message-ID: <546DEC79.9050807@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 20 Nov 2014 14:22:47 +0100

The of_dev_put() function tests whether its argument is NULL and then
returns immediately. Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/ibm/emac/core.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 87bd953..3f3fba9 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2323,16 +2323,11 @@ static int emac_check_deps(struct emac_instance *dev,
 
 static void emac_put_deps(struct emac_instance *dev)
 {
-	if (dev->mal_dev)
-		of_dev_put(dev->mal_dev);
-	if (dev->zmii_dev)
-		of_dev_put(dev->zmii_dev);
-	if (dev->rgmii_dev)
-		of_dev_put(dev->rgmii_dev);
-	if (dev->mdio_dev)
-		of_dev_put(dev->mdio_dev);
-	if (dev->tah_dev)
-		of_dev_put(dev->tah_dev);
+	of_dev_put(dev->mal_dev);
+	of_dev_put(dev->zmii_dev);
+	of_dev_put(dev->rgmii_dev);
+	of_dev_put(dev->mdio_dev);
+	of_dev_put(dev->tah_dev);
 }
 
 static int emac_of_bus_notify(struct notifier_block *nb, unsigned long action,
@@ -2371,8 +2366,7 @@ static int emac_wait_deps(struct emac_instance *dev)
 	bus_unregister_notifier(&platform_bus_type, &emac_of_bus_notifier);
 	err = emac_check_deps(dev, deps) ? 0 : -ENODEV;
 	for (i = 0; i < EMAC_DEP_COUNT; i++) {
-		if (deps[i].node)
-			of_node_put(deps[i].node);
+		of_node_put(deps[i].node);
 		if (err && deps[i].ofdev)
 			of_dev_put(deps[i].ofdev);
 	}
@@ -2383,8 +2377,7 @@ static int emac_wait_deps(struct emac_instance *dev)
 		dev->tah_dev = deps[EMAC_DEP_TAH_IDX].ofdev;
 		dev->mdio_dev = deps[EMAC_DEP_MDIO_IDX].ofdev;
 	}
-	if (deps[EMAC_DEP_PREV_IDX].ofdev)
-		of_dev_put(deps[EMAC_DEP_PREV_IDX].ofdev);
+	of_dev_put(deps[EMAC_DEP_PREV_IDX].ofdev);
 	return err;
 }
 
@@ -3113,8 +3106,7 @@ static void __exit emac_exit(void)
 
 	/* Destroy EMAC boot list */
 	for (i = 0; i < EMAC_BOOT_LIST_SIZE; i++)
-		if (emac_boot_list[i])
-			of_node_put(emac_boot_list[i]);
+		of_node_put(emac_boot_list[i]);
 }
 
 module_init(emac_init);
-- 
2.1.3

