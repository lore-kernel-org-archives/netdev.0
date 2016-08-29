From: robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org
Subject: [PATCH v3 5/5] net: asix: autoneg will set WRITE_MEDIUM reg
Date: Mon, 29 Aug 2016 09:32:19 -0400
Message-ID: <9d5c5525f369f1c4098bda989d73886d11036bae.1472155176.git-series.robert.foss__38271.7433888049$1472477665$gmane$org@collabora.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
Cc: Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org, Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org,
        Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org, ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
        stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
        changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
In-Reply-To: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>

From: Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

The miii_nway_restart() causes a PHY link change activity and
ax88772_link_reset will be called. link_reset will set
AX_CMD_WRITE_MEDIUM_MODE register correctly.

The asix_write_medium_mode in reset() fills in a default value to the register
which may be different from the negotiation result. So do this first.

Ignore the ret value since it's ignored in XXX_link_reset() functions.

Signed-off-by: Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Tested-by: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
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
