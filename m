From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/2] net/can: use module_pci_driver
Date: Mon, 16 Apr 2012 21:32:26 +0200
Message-ID: <1334604746-24556-3-git-send-email-mkl@pengutronix.de>
References: <1334604746-24556-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Axel Lin <axel.lin@gmail.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1334604746-24556-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Axel Lin <axel.lin@gmail.com>

This patch converts the drivers in drivers/net/can/* to use
module_pci_driver() macro which makes the code smaller and a bit simpler.

Signed-off-by: Axel Lin <axel.lin@gmail.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-can@vger.kernel.org
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/pch_can.c            |   12 +-----------
 drivers/net/can/sja1000/ems_pci.c    |   14 +-------------
 drivers/net/can/sja1000/kvaser_pci.c |   13 +------------
 drivers/net/can/sja1000/peak_pci.c   |   12 +-----------
 drivers/net/can/sja1000/plx_pci.c    |   13 +------------
 5 files changed, 5 insertions(+), 59 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 2bb215e..1226297 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -1274,17 +1274,7 @@ static struct pci_driver pch_can_pci_driver = {
 	.resume = pch_can_resume,
 };
 
-static int __init pch_can_pci_init(void)
-{
-	return pci_register_driver(&pch_can_pci_driver);
-}
-module_init(pch_can_pci_init);
-
-static void __exit pch_can_pci_exit(void)
-{
-	pci_unregister_driver(&pch_can_pci_driver);
-}
-module_exit(pch_can_pci_exit);
+module_pci_driver(pch_can_pci_driver);
 
 MODULE_DESCRIPTION("Intel EG20T PCH CAN(Controller Area Network) Driver");
 MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/can/sja1000/ems_pci.c b/drivers/net/can/sja1000/ems_pci.c
index 36f4f97..5c6d412 100644
--- a/drivers/net/can/sja1000/ems_pci.c
+++ b/drivers/net/can/sja1000/ems_pci.c
@@ -371,16 +371,4 @@ static struct pci_driver ems_pci_driver = {
 	.remove = ems_pci_del_card,
 };
 
-static int __init ems_pci_init(void)
-{
-	return pci_register_driver(&ems_pci_driver);
-}
-
-static void __exit ems_pci_exit(void)
-{
-	pci_unregister_driver(&ems_pci_driver);
-}
-
-module_init(ems_pci_init);
-module_exit(ems_pci_exit);
-
+module_pci_driver(ems_pci_driver);
diff --git a/drivers/net/can/sja1000/kvaser_pci.c b/drivers/net/can/sja1000/kvaser_pci.c
index ed004ce..23ed6ea 100644
--- a/drivers/net/can/sja1000/kvaser_pci.c
+++ b/drivers/net/can/sja1000/kvaser_pci.c
@@ -397,15 +397,4 @@ static struct pci_driver kvaser_pci_driver = {
 	.remove = __devexit_p(kvaser_pci_remove_one),
 };
 
-static int __init kvaser_pci_init(void)
-{
-	return pci_register_driver(&kvaser_pci_driver);
-}
-
-static void __exit kvaser_pci_exit(void)
-{
-	pci_unregister_driver(&kvaser_pci_driver);
-}
-
-module_init(kvaser_pci_init);
-module_exit(kvaser_pci_exit);
+module_pci_driver(kvaser_pci_driver);
diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index 5f92b86..f0a1296 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -749,14 +749,4 @@ static struct pci_driver peak_pci_driver = {
 	.remove = __devexit_p(peak_pci_remove),
 };
 
-static int __init peak_pci_init(void)
-{
-	return pci_register_driver(&peak_pci_driver);
-}
-module_init(peak_pci_init);
-
-static void __exit peak_pci_exit(void)
-{
-	pci_unregister_driver(&peak_pci_driver);
-}
-module_exit(peak_pci_exit);
+module_pci_driver(peak_pci_driver);
diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
index a227586..8bc9598 100644
--- a/drivers/net/can/sja1000/plx_pci.c
+++ b/drivers/net/can/sja1000/plx_pci.c
@@ -609,15 +609,4 @@ static struct pci_driver plx_pci_driver = {
 	.remove = plx_pci_del_card,
 };
 
-static int __init plx_pci_init(void)
-{
-	return pci_register_driver(&plx_pci_driver);
-}
-
-static void __exit plx_pci_exit(void)
-{
-	pci_unregister_driver(&plx_pci_driver);
-}
-
-module_init(plx_pci_init);
-module_exit(plx_pci_exit);
+module_pci_driver(plx_pci_driver);
-- 
1.7.4.1

