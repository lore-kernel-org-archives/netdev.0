From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 09/10] net: phy: add "has_fixups" boolean property
Date: Tue, 11 Feb 2014 17:27:41 -0800
Message-ID: <1392168462-18888-10-git-send-email-f.fainelli@gmail.com>
References: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:23636 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbaBLB2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:28:19 -0500
In-Reply-To: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a boolean property which indicates if the PHY has had any fixup
routine ran on it. We are later going to use that boolean to expose it
as a sysfs property to help troubleshooting.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 1 +
 include/linux/phy.h          | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 7c18420..c2d778d 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -139,6 +139,7 @@ static int phy_scan_fixups(struct phy_device *phydev)
 				mutex_unlock(&phy_fixup_lock);
 				return err;
 			}
+			phydev->has_fixups = true;
 		}
 	}
 	mutex_unlock(&phy_fixup_lock);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index ef7fa11..42f1bc7 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -350,6 +350,7 @@ struct phy_device {
 	struct phy_c45_device_ids c45_ids;
 	bool is_c45;
 	bool is_internal;
+	bool has_fixups;
 
 	enum phy_state state;
 
-- 
1.8.3.2
