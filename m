From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v2 2/3] net: phy: leds: Break dependency of phy.h on phy_led_triggers.h
Date: Wed, 25 Jan 2017 11:39:49 +0100
Message-ID: <1485340790-10785-3-git-send-email-geert+renesas@glider.be>
References: <1485340790-10785-1-git-send-email-geert+renesas@glider.be>
Cc: Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?q?Magnus=20=C3=96berg?= <magnus.oberg@westermo.se>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Zach Brown <zach.brown@ni.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1485340790-10785-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

<linux/phy.h> includes <linux/phy_led_triggers.h>, which is not really
needed.  Drop the include from <linux/phy.h>, and add it to all users
that didn't include it explicitly.

Suggested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
v2:
  - New.
---
 drivers/net/phy/phy.c              | 1 +
 drivers/net/phy/phy_led_triggers.c | 1 +
 include/linux/phy.h                | 1 -
 3 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 48da6e93c3f783e0..807abd6e331f8aa2 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -29,6 +29,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/phy_led_triggers.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/mdio.h>
diff --git a/drivers/net/phy/phy_led_triggers.c b/drivers/net/phy/phy_led_triggers.c
index 3f619e7371e97d8a..94ca42e630bbead0 100644
--- a/drivers/net/phy/phy_led_triggers.c
+++ b/drivers/net/phy/phy_led_triggers.c
@@ -12,6 +12,7 @@
  */
 #include <linux/leds.h>
 #include <linux/phy.h>
+#include <linux/phy_led_triggers.h>
 #include <linux/netdevice.h>
 
 static struct phy_led_trigger *phy_speed_to_led_trigger(struct phy_device *phy,
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 5c9d2529685fe215..43474f39ef6523c5 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -25,7 +25,6 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/mod_devicetable.h>
-#include <linux/phy_led_triggers.h>
 
 #include <linux/atomic.h>
 
-- 
1.9.1
