From: Dan Murphy <dmurphy@ti.com>
Subject: [PATCH 3/3 v2] net: phy: Change error to EINVAL for invalid MAC
Date: Wed, 4 Oct 2017 13:20:31 -0500
Message-ID: <20171004182031.13794-3-dmurphy@ti.com>
References: <20171004182031.13794-1-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <afd@ti.com>, Dan Murphy <dmurphy@ti.com>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:24915 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751177AbdJDSUn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 14:20:43 -0400
In-Reply-To: <20171004182031.13794-1-dmurphy@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the return error code to EINVAL if the MAC
address is not valid in the set_wol function.

Signed-off-by: Dan Murphy <dmurphy@ti.com>
---

v2 - There was no v1 on this patch this is new.

 drivers/net/phy/at803x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index c1e52b9dc58d..5f93e6add563 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -167,7 +167,7 @@ static int at803x_set_wol(struct phy_device *phydev,
 		mac = (const u8 *) ndev->dev_addr;
 
 		if (!is_valid_ether_addr(mac))
-			return -EFAULT;
+			return -EINVAL;
 
 		for (i = 0; i < 3; i++) {
 			phy_write(phydev, AT803X_MMD_ACCESS_CONTROL,
-- 
2.14.0
