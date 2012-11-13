From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH 3.7.0-rc4] of/net/mdio-gpio: Fix pdev->id issue when using devicetrees.
Date: Tue, 13 Nov 2012 14:26:13 +0000
Message-ID: <1352816773-17837-1-git-send-email-srinivas.kandagatla@st.com>
Cc: davem@davemloft.net, devicetree-discuss@lists.ozlabs.org,
	srinivas.kandagatla@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:36552 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754540Ab2KMO05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 09:26:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

When the mdio-gpio driver is probed via device trees, the platform
device id is set as -1, However the id is re-used in the code while
creating an mdio bus.
So, setting up the id via aliases from device tree is a sensible
solution to fix this issue.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 .../devicetree/bindings/net/mdio-gpio.txt          |    9 ++++++++-
 drivers/net/phy/mdio-gpio.c                        |    1 +
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/mdio-gpio.txt b/Documentation/devicetree/bindings/net/mdio-gpio.txt
index bc95495..c79bab0 100644
--- a/Documentation/devicetree/bindings/net/mdio-gpio.txt
+++ b/Documentation/devicetree/bindings/net/mdio-gpio.txt
@@ -8,9 +8,16 @@ gpios property as described in section VIII.1 in the following order:
 
 MDC, MDIO.
 
+Note: Each gpio-mdio bus should have an alias correctly numbered in "aliases"
+node.
+
 Example:
 
-mdio {
+aliases {
+	mdio-gpio0 = <&mdio0>;
+};
+
+mdio0: mdio {
 	compatible = "virtual,mdio-gpio";
 	#address-cells = <1>;
 	#size-cells = <0>;
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 899274f..e3f3115 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -56,6 +56,7 @@ static void *mdio_gpio_of_get_data(struct platform_device *pdev)
 	if (ret < 0)
 		return NULL;
 	pdata->mdio = ret;
+	pdev->id = of_alias_get_id(np, "mdio-gpio");
 
 	return pdata;
 }
-- 
1.7.0.4
