From: Mason <slash.tmp@free.fr>
Subject: [RFC PATCH v2 2/2] net: ethernet: nb8800: Add suspend/resume support
Date: Tue, 1 Aug 2017 18:43:56 +0200
Message-ID: <9e7bbeac-748d-c837-f621-89ab728d5c2f@free.fr>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:31535 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751755AbdHAQp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 12:45:26 -0400
In-Reply-To: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrappers around nb8800_stop and nb8800_open.
---
 drivers/net/ethernet/aurora/nb8800.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index aa18ea25d91f..607064a6d7a1 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1012,7 +1012,6 @@ static int nb8800_stop(struct net_device *dev)
 	netif_stop_queue(dev);
 	napi_disable(&priv->napi);
 
-	nb8800_dma_stop(dev);
 	nb8800_mac_rx(dev, false);
 	nb8800_mac_tx(dev, false);
 
@@ -1526,6 +1525,26 @@ static int nb8800_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static int nb8800_suspend(struct platform_device *pdev, pm_message_t state)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	if (netif_running(dev))
+		nb8800_stop(dev);
+
+	return 0;
+}
+
+static int nb8800_resume(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	if (netif_running(dev))
+		nb8800_open(dev);
+
+	return 0;
+}
+
 static struct platform_driver nb8800_driver = {
 	.driver = {
 		.name		= "nb8800",
@@ -1533,6 +1552,8 @@ static struct platform_driver nb8800_driver = {
 	},
 	.probe	= nb8800_probe,
 	.remove	= nb8800_remove,
+	.suspend = nb8800_suspend,
+	.resume = nb8800_resume,
 };
 
 module_platform_driver(nb8800_driver);
-- 
2.11.0
