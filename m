From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v1 4/6] net: phy: resume/suspend PHYs on attach/detach
Date: Sun,  8 Dec 2013 15:40:29 +0100
Message-ID: <1386513631-11284-5-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1386171888-28190-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1386513631-11284-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55040 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759153Ab3LHOkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 09:40:39 -0500
In-Reply-To: <1386513631-11284-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ensures PHYs are resumed on attach and suspended on detach.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
Cc: David Miller <davem@davemloft.net>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/phy/phy_device.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 6f0e9e4..3903f44 100644
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
1.8.4.rc3
