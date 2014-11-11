From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 2/3] net: phy: replace phy_driver_register calls
Date: Tue, 11 Nov 2014 19:45:58 +0100
Message-ID: <1415731559-10015-3-git-send-email-johan@kernel.org>
References: <1415731559-10015-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415731559-10015-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace module init/exit which only calls phy_driver_register with
module_phy_driver macro.

Compile tested only.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/amd.c      | 17 +++--------------
 drivers/net/phy/et1011c.c  | 17 +++--------------
 drivers/net/phy/national.c | 17 +++--------------
 drivers/net/phy/qsemi.c    | 17 +++--------------
 4 files changed, 12 insertions(+), 56 deletions(-)

diff --git a/drivers/net/phy/amd.c b/drivers/net/phy/amd.c
index a3fb5ceb6487..65a488f82eb8 100644
--- a/drivers/net/phy/amd.c
+++ b/drivers/net/phy/amd.c
@@ -61,7 +61,7 @@ static int am79c_config_intr(struct phy_device *phydev)
 	return err;
 }
 
-static struct phy_driver am79c_driver = {
+static struct phy_driver am79c_driver[] = { {
 	.phy_id		= PHY_ID_AM79C874,
 	.name		= "AM79C874",
 	.phy_id_mask	= 0xfffffff0,
@@ -73,20 +73,9 @@ static struct phy_driver am79c_driver = {
 	.ack_interrupt	= am79c_ack_interrupt,
 	.config_intr	= am79c_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
-};
-
-static int __init am79c_init(void)
-{
-	return phy_driver_register(&am79c_driver);
-}
-
-static void __exit am79c_exit(void)
-{
-	phy_driver_unregister(&am79c_driver);
-}
+} };
 
-module_init(am79c_init);
-module_exit(am79c_exit);
+module_phy_driver(am79c_driver);
 
 static struct mdio_device_id __maybe_unused amd_tbl[] = {
 	{ PHY_ID_AM79C874, 0xfffffff0 },
diff --git a/drivers/net/phy/et1011c.c b/drivers/net/phy/et1011c.c
index a8eb19ec3183..a907743816a8 100644
--- a/drivers/net/phy/et1011c.c
+++ b/drivers/net/phy/et1011c.c
@@ -87,7 +87,7 @@ static int et1011c_read_status(struct phy_device *phydev)
 	return ret;
 }
 
-static struct phy_driver et1011c_driver = {
+static struct phy_driver et1011c_driver[] = { {
 	.phy_id		= 0x0282f014,
 	.name		= "ET1011C",
 	.phy_id_mask	= 0xfffffff0,
@@ -96,20 +96,9 @@ static struct phy_driver et1011c_driver = {
 	.config_aneg	= et1011c_config_aneg,
 	.read_status	= et1011c_read_status,
 	.driver 	= { .owner = THIS_MODULE,},
-};
-
-static int __init et1011c_init(void)
-{
-	return phy_driver_register(&et1011c_driver);
-}
-
-static void __exit et1011c_exit(void)
-{
-	phy_driver_unregister(&et1011c_driver);
-}
+} };
 
-module_init(et1011c_init);
-module_exit(et1011c_exit);
+module_phy_driver(et1011c_driver);
 
 static struct mdio_device_id __maybe_unused et1011c_tbl[] = {
 	{ 0x0282f014, 0xfffffff0 },
diff --git a/drivers/net/phy/national.c b/drivers/net/phy/national.c
index 9a5f234d95b0..0a7b9c7f09a2 100644
--- a/drivers/net/phy/national.c
+++ b/drivers/net/phy/national.c
@@ -129,7 +129,7 @@ static int ns_config_init(struct phy_device *phydev)
 	return ns_ack_interrupt(phydev);
 }
 
-static struct phy_driver dp83865_driver = {
+static struct phy_driver dp83865_driver[] = { {
 	.phy_id = DP83865_PHY_ID,
 	.phy_id_mask = 0xfffffff0,
 	.name = "NatSemi DP83865",
@@ -141,25 +141,14 @@ static struct phy_driver dp83865_driver = {
 	.ack_interrupt = ns_ack_interrupt,
 	.config_intr = ns_config_intr,
 	.driver = {.owner = THIS_MODULE,}
-};
+} };
 
-static int __init ns_init(void)
-{
-	return phy_driver_register(&dp83865_driver);
-}
-
-static void __exit ns_exit(void)
-{
-	phy_driver_unregister(&dp83865_driver);
-}
+module_phy_driver(dp83865_driver);
 
 MODULE_DESCRIPTION("NatSemi PHY driver");
 MODULE_AUTHOR("Stuart Menefy");
 MODULE_LICENSE("GPL");
 
-module_init(ns_init);
-module_exit(ns_exit);
-
 static struct mdio_device_id __maybe_unused ns_tbl[] = {
 	{ DP83865_PHY_ID, 0xfffffff0 },
 	{ }
diff --git a/drivers/net/phy/qsemi.c b/drivers/net/phy/qsemi.c
index fe0d0a15d5e1..be4c6f7c3645 100644
--- a/drivers/net/phy/qsemi.c
+++ b/drivers/net/phy/qsemi.c
@@ -111,7 +111,7 @@ static int qs6612_config_intr(struct phy_device *phydev)
 
 }
 
-static struct phy_driver qs6612_driver = {
+static struct phy_driver qs6612_driver[] = { {
 	.phy_id		= 0x00181440,
 	.name		= "QS6612",
 	.phy_id_mask	= 0xfffffff0,
@@ -123,20 +123,9 @@ static struct phy_driver qs6612_driver = {
 	.ack_interrupt	= qs6612_ack_interrupt,
 	.config_intr	= qs6612_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
-};
-
-static int __init qs6612_init(void)
-{
-	return phy_driver_register(&qs6612_driver);
-}
-
-static void __exit qs6612_exit(void)
-{
-	phy_driver_unregister(&qs6612_driver);
-}
+} };
 
-module_init(qs6612_init);
-module_exit(qs6612_exit);
+module_phy_driver(qs6612_driver);
 
 static struct mdio_device_id __maybe_unused qs6612_tbl[] = {
 	{ 0x00181440, 0xfffffff0 },
-- 
2.0.4
