From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: [PATCH 2/4] net: smsc911x: add a reset GPIO DT binding
Date: Tue, 23 Jul 2013 18:12:02 +0200
Message-ID: <1374595924-12338-3-git-send-email-g.liakhovetski@gmx.de>
References: <1374595924-12338-1-git-send-email-g.liakhovetski@gmx.de>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org,
	Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>,
	devicetree@vger.kernel.org
To: linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:49231 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933537Ab3GWQMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 12:12:08 -0400
In-Reply-To: <1374595924-12338-1-git-send-email-g.liakhovetski@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new DT property to specify a reset GPIO.

Signed-off-by: Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>
Cc: devicetree@vger.kernel.org
---
 Documentation/devicetree/bindings/net/smsc911x.txt |    1 +
 drivers/net/ethernet/smsc/smsc911x.c               |   11 +++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/smsc911x.txt b/Documentation/devicetree/bindings/net/smsc911x.txt
index adb5b57..2bf32be 100644
--- a/Documentation/devicetree/bindings/net/smsc911x.txt
+++ b/Documentation/devicetree/bindings/net/smsc911x.txt
@@ -23,6 +23,7 @@ Optional properties:
   external PHY
 - smsc,save-mac-address : Indicates that mac address needs to be saved
   before resetting the controller
+- smsc,reset-gpios : a GPIO binding to take the controller out of reset
 - local-mac-address : 6 bytes, mac address
 
 Examples:
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index ca01c03..db6255e 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2328,6 +2328,8 @@ static int smsc911x_probe_config_dt(struct smsc911x_platform_config *config,
 {
 	const char *mac;
 	u32 width = 0;
+	enum of_gpio_flags flags;
+	int gpio;
 
 	if (!np)
 		return -ENODEV;
@@ -2361,6 +2363,15 @@ static int smsc911x_probe_config_dt(struct smsc911x_platform_config *config,
 	if (of_get_property(np, "smsc,save-mac-address", NULL))
 		config->flags |= SMSC911X_SAVE_MAC_ADDRESS;
 
+	gpio = of_get_named_gpio_flags(np, "smsc,reset-gpios", 0, &flags);
+	if (gpio == -EPROBE_DEFER)
+		return gpio;
+	if (gpio_is_valid(gpio)) {
+		config->reset_gpio = gpio;
+		config->reset_gpio_config = SMSC911X_RESET_GPIO_VALID |
+			(flags & OF_GPIO_ACTIVE_LOW ? GPIOF_INIT_LOW : GPIOF_INIT_HIGH);
+	}
+
 	return 0;
 }
 #else
-- 
1.7.2.5
