From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCHv3 5/5] net: rfkill: gpio: hard-code the gpio names
Date: Tue,  1 Apr 2014 17:02:56 +0300
Message-ID: <1396360976-28657-6-git-send-email-heikki.krogerus@linux.intel.com>
References: <1396360976-28657-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: Chen-Yu Tsai <wens@csie.org>, Rhyland Klein <rklein@nvidia.com>,
	Marc Dietrich <marvin24@gmx.de>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Alexandre Courbot <gnurou@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-tegra@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396360976-28657-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need to dynamically generate the names. This
will fix a static checker warning..

net/rfkill/rfkill-gpio.c:144 rfkill_gpio_probe()
    warn: variable dereferenced before check 'rfkill->name'

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
---
 net/rfkill/rfkill-gpio.c | 19 ++-----------------
 1 file changed, 2 insertions(+), 17 deletions(-)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 436bffb..9c4a5eb 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -36,8 +36,6 @@ struct rfkill_gpio_data {
 	struct gpio_desc	*shutdown_gpio;
 
 	struct rfkill		*rfkill_dev;
-	char			*reset_name;
-	char			*shutdown_name;
 	struct clk		*clk;
 
 	bool			clk_enabled;
@@ -89,7 +87,6 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 	struct rfkill_gpio_data *rfkill;
 	struct gpio_desc *gpio;
 	int ret;
-	int len;
 
 	rfkill = devm_kzalloc(&pdev->dev, sizeof(*rfkill), GFP_KERNEL);
 	if (!rfkill)
@@ -106,21 +103,9 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
-	len = strlen(rfkill->name);
-	rfkill->reset_name = devm_kzalloc(&pdev->dev, len + 7, GFP_KERNEL);
-	if (!rfkill->reset_name)
-		return -ENOMEM;
-
-	rfkill->shutdown_name = devm_kzalloc(&pdev->dev, len + 10, GFP_KERNEL);
-	if (!rfkill->shutdown_name)
-		return -ENOMEM;
-
-	snprintf(rfkill->reset_name, len + 6 , "%s_reset", rfkill->name);
-	snprintf(rfkill->shutdown_name, len + 9, "%s_shutdown", rfkill->name);
-
 	rfkill->clk = devm_clk_get(&pdev->dev, NULL);
 
-	gpio = devm_gpiod_get_index(&pdev->dev, rfkill->reset_name, 0);
+	gpio = devm_gpiod_get_index(&pdev->dev, "reset", 0);
 	if (!IS_ERR(gpio)) {
 		ret = gpiod_direction_output(gpio, 0);
 		if (ret)
@@ -128,7 +113,7 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 		rfkill->reset_gpio = gpio;
 	}
 
-	gpio = devm_gpiod_get_index(&pdev->dev, rfkill->shutdown_name, 1);
+	gpio = devm_gpiod_get_index(&pdev->dev, "shutdown", 1);
 	if (!IS_ERR(gpio)) {
 		ret = gpiod_direction_output(gpio, 0);
 		if (ret)
-- 
1.9.1
