From: "Rini van Zetten" <rini@arvoo.nl>
Subject: [PATCH]drivers/net/phy/: default return value in ioctl phy.c
Date: Tue, 11 Dec 2007 16:02:31 +0100
Message-ID: <014901c83c06$da9223e0$2b00a8c0@ARV127>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.euronet.nl ([194.134.35.173]:54915 "EHLO smtp3.euronet.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751334AbXLKPUn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 10:20:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Andy,

This patch (to 2.6.23.9) add a default return value EOPNOTSUPP to the ioctl 
function. The problem with the always 0 return value is that the iwconfig 
(wireless) tool found a valid device when an ethernet device uses the phy 
abstraction layer.
I 've tetsted this with the macb driver.


Signed-off-by: Rini van Zetten <rini@arvoo.nl>

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index cb230f4..c07460d 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -405,6 +405,8 @@ int phy_mii_ioctl(struct phy_device *phydev,
                                && phydev->drv->config_init)
                        phydev->drv->config_init(phydev);
                break;
+       default:
+               return -EOPNOTSUPP;
        }

        return 0;

