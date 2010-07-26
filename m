From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] ethoc: add devinit/devexit section initializers
Date: Mon, 26 Jul 2010 16:01:01 +0200
Message-ID: <1280152861-11210-1-git-send-email-jonas@southpole.se>
Cc: thomas@wytron.com.tw, Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:41920 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373Ab0GZOSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 10:18:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index fc26097..7fc2de5 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -637,7 +637,7 @@ static void ethoc_mdio_poll(struct net_device *dev)
 {
 }
 
-static int ethoc_mdio_probe(struct net_device *dev)
+static int __devinit ethoc_mdio_probe(struct net_device *dev)
 {
 	struct ethoc *priv = netdev_priv(dev);
 	struct phy_device *phy;
@@ -877,7 +877,7 @@ static const struct net_device_ops ethoc_netdev_ops = {
  * ethoc_probe() - initialize OpenCores ethernet MAC
  * pdev:	platform device
  */
-static int ethoc_probe(struct platform_device *pdev)
+static int __devinit ethoc_probe(struct platform_device *pdev)
 {
 	struct net_device *netdev = NULL;
 	struct resource *res = NULL;
@@ -1088,7 +1088,7 @@ out:
  * ethoc_remove() - shutdown OpenCores ethernet MAC
  * @pdev:	platform device
  */
-static int ethoc_remove(struct platform_device *pdev)
+static int __devexit ethoc_remove(struct platform_device *pdev)
 {
 	struct net_device *netdev = platform_get_drvdata(pdev);
 	struct ethoc *priv = netdev_priv(netdev);
@@ -1142,7 +1142,7 @@ MODULE_DEVICE_TABLE(of, ethoc_match);
 
 static struct platform_driver ethoc_driver = {
 	.probe   = ethoc_probe,
-	.remove  = ethoc_remove,
+	.remove  = __devexit_p(ethoc_remove),
 	.suspend = ethoc_suspend,
 	.resume  = ethoc_resume,
 	.driver  = {
-- 
1.7.1

