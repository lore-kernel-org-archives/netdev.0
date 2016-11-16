From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 1/3] of_mdio: fix node leak in of_phy_register_fixed_link error path
Date: Wed, 16 Nov 2016 15:20:36 +0100
Message-ID: <1479306038-27211-2-git-send-email-johan@kernel.org>
References: <1479306038-27211-1-git-send-email-johan@kernel.org>
Cc: Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479306038-27211-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to drop the of_node reference also on failure to parse the
speed property in of_phy_register_fixed_link().

Fixes: 3be2a49e5c08 ("of: provide a binding for fixed link PHYs")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/of/of_mdio.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index b470f7e3521d..8f4648383fb2 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -456,8 +456,11 @@ int of_phy_register_fixed_link(struct device_node *np)
 		status.link = 1;
 		status.duplex = of_property_read_bool(fixed_link_node,
 						      "full-duplex");
-		if (of_property_read_u32(fixed_link_node, "speed", &status.speed))
+		if (of_property_read_u32(fixed_link_node, "speed",
+					 &status.speed)) {
+			of_node_put(fixed_link_node);
 			return -EINVAL;
+		}
 		status.pause = of_property_read_bool(fixed_link_node, "pause");
 		status.asym_pause = of_property_read_bool(fixed_link_node,
 							  "asym-pause");
-- 
2.7.3
