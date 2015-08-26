From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH] net: phy: fixed: propagate fixed link values to struct
Date: Wed, 26 Aug 2015 17:48:28 +0300
Message-ID: <1440600508-7531-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<Igal.Liberman@freescale.com>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <f.fainelli@gmail.com>, <stsp@list.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The fixed link values parsed from the device tree are stored in
the struct fixed_phy member status. The struct phy_device members
speed, duplex were not updated.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/phy/fixed_phy.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 479b93f..20731fc 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -292,6 +292,15 @@ struct phy_device *fixed_phy_register(unsigned int irq,
 		return ERR_PTR(-EINVAL);
 	}
 
+	/* propagate the fixed link values to struct phy_device */
+	if (status->link) {
+		phy->link = status->link;
+		phy->speed = status->speed;
+		phy->duplex = status->duplex;
+		phy->pause = status->pause;
+		phy->asym_pause = status->asym_pause;
+	}
+
 	of_node_get(np);
 	phy->dev.of_node = np;
 
-- 
1.7.11.7
