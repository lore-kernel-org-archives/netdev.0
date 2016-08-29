From: robert.foss@collabora.com
Subject: [PATCH v3 5/5] net: asix: autoneg will set WRITE_MEDIUM reg
Date: Mon, 29 Aug 2016 09:32:24 -0400
Message-ID: <1472477566-32096-5-git-send-email-robert.foss@collabora.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
Cc: Grant Grundler <grundler@google.com>
To: freddy@asix.com.tw, Dean_Jenkins@mentor.com,
        Mark_Craske@mentor.com, davem@davemloft.net,
        robert.foss@collabora.com, ivecera@redhat.com,
        john.stultz@linaro.org, vpalatin@chromium.org,
        stephen@networkplumber.org, grundler@chromium.org,
        changchias@gmail.com, allan@asix.com.tw, andrew@lunn.ch,
        tremyfr@gmail.com, colin.king@canonical.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, vpalatin@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:52488 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932923AbcH2NgK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:36:10 -0400
In-Reply-To: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@chromium.org>

The miii_nway_restart() causes a PHY link change activity and
ax88772_link_reset will be called. link_reset will set
AX_CMD_WRITE_MEDIUM_MODE register correctly.

The asix_write_medium_mode in reset() fills in a default value to the register
which may be different from the negotiation result. So do this first.

Ignore the ret value since it's ignored in XXX_link_reset() functions.

Signed-off-by: Grant Grundler <grundler@google.com>
Signed-off-by: Robert Foss <robert.foss@collabora.com>
Tested-by: Robert Foss <robert.foss@collabora.com>
---
 drivers/net/usb/asix_devices.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index dbcdda2..cce2495 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -928,12 +928,9 @@ static int ax88178_reset(struct usbnet *dev)
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_CTRL1000,
 			ADVERTISE_1000FULL);
 
+	asix_write_medium_mode(dev, AX88178_MEDIUM_DEFAULT, 0);
 	mii_nway_restart(&dev->mii);
 
-	ret = asix_write_medium_mode(dev, AX88178_MEDIUM_DEFAULT, 0);
-	if (ret < 0)
-		return ret;
-
 	/* Rewrite MAC address */
 	memcpy(data->mac_addr, dev->net->dev_addr, ETH_ALEN);
 	ret = asix_write_cmd(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
-- 
2.7.4
