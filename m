From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH 6/6] net: phy: Stop 'phy-state-machine' and 'phy_change' work
 on remove
Date: Tue, 27 Oct 2015 15:49:21 +0100
Message-ID: <562F8EF1.5090504@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33539 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932466AbbJ0Ot0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 10:49:26 -0400
Received: by wijp11 with SMTP id p11so217545518wij.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 07:49:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoids:
 Unable to handle kernel NULL pointer dereference at virtual address 00000064
 Workqueue: events_power_efficient phy_state_machine
 PC is at phy_state_machine+0x28/0x480

Signed-off-by: Frode Isaksen <fisaksen@baylibre.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/phy/phy_device.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 3833891..b5b6c1b 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1348,6 +1348,12 @@ static int phy_remove(struct device *dev)
 	phydev->state = PHY_DOWN;
 	mutex_unlock(&phydev->lock);

+	cancel_delayed_work_sync(&phydev->state_queue);
+	flush_delayed_work(&phydev->state_queue);
+
+	cancel_work_sync(&phydev->phy_queue);
+	flush_work(&phydev->phy_queue);
+
 	if (phydev->drv->remove)
 		phydev->drv->remove(phydev);
 	phydev->drv = NULL;
-- 
1.9.1
