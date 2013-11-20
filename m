From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH RFC v1 3/7] net: phy: resume/suspend PHYs on attach/detach
Date: Wed, 20 Nov 2013 21:21:49 +0100
Message-ID: <1384978913-8052-4-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This ensures PHYs are resumed on attach and suspended on detach.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/phy/phy_device.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 2442895..a421fc6 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -570,6 +570,8 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	if (err)
 		phy_detach(phydev);
 
+	phy_resume(phydev);
+
 	return err;
 }
 
@@ -615,6 +617,7 @@ void phy_detach(struct phy_device *phydev)
 {
 	phydev->attached_dev->phydev = NULL;
 	phydev->attached_dev = NULL;
+	phy_suspend(phydev);
 
 	/* If the device had no specific driver before (i.e. - it
 	 * was using the generic driver), we unbind the device
-- 
1.7.2.5
