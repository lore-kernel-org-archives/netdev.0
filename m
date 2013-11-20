From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH RFC v1 2/7] net: phy: provide phy_resume/phy_suspend helpers
Date: Wed, 20 Nov 2013 21:21:48 +0100
Message-ID: <1384978913-8052-3-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds helper functions to resume and suspend a given phy_device
by calling the corresponding driver callbacks if available.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/phy/phy_device.c |   19 +++++++++++++++++++
 include/linux/phy.h          |    2 ++
 2 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 74630e9..2442895 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -625,6 +625,25 @@ void phy_detach(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_detach);
 
+int phy_suspend(struct phy_device *phydev)
+{
+	struct phy_driver *phydrv = to_phy_driver(phydev->dev.driver);
+
+	if (phydrv->suspend)
+		return phydrv->suspend(phydev);
+	return 0;
+}
+EXPORT_SYMBOL(phy_suspend);
+
+int phy_resume(struct phy_device *phydev)
+{
+	struct phy_driver *phydrv = to_phy_driver(phydev->dev.driver);
+
+	if (phydrv->resume)
+		return phydrv->resume(phydev);
+	return 0;
+}
+EXPORT_SYMBOL(phy_resume);
 
 /* Generic PHY support and helper functions */
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 64ab823..ed0d6d8 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -552,6 +552,8 @@ void phy_detach(struct phy_device *phydev);
 void phy_start(struct phy_device *phydev);
 void phy_stop(struct phy_device *phydev);
 int phy_start_aneg(struct phy_device *phydev);
+int phy_suspend(struct phy_device *phydev);
+int phy_resume(struct phy_device *phydev);
 
 int phy_stop_interrupts(struct phy_device *phydev);
 
-- 
1.7.2.5
