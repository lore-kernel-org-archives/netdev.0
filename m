From: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 04/11] net: usb: cdc_ncm: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 16 Mar 2017 23:18:50 +0100
Message-ID: <1489702737-2401-5-git-send-email-tremyfr@gmail.com>
References: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org,
        steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org, UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org,
        gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org, allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org, grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        jarod-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, peter.chen-3arQi8VN3Tc@public.gmane.org, stefan.bruens-vA1bhqPz9FBZXbeN9DUtxg@public.gmane.org,
        akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489702737-2401-1-git-send-email-tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index f317984..b6c1d3a 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -131,8 +131,6 @@ static void cdc_ncm_get_strings(struct net_device __always_unused *netdev, u32 s
 static void cdc_ncm_update_rxtx_max(struct usbnet *dev, u32 new_rx, u32 new_tx);
 
 static const struct ethtool_ops cdc_ncm_ethtool_ops = {
-	.get_settings      = usbnet_get_settings,
-	.set_settings      = usbnet_set_settings,
 	.get_link          = usbnet_get_link,
 	.nway_reset        = usbnet_nway_reset,
 	.get_drvinfo       = usbnet_get_drvinfo,
@@ -142,6 +140,8 @@ static void cdc_ncm_get_strings(struct net_device __always_unused *netdev, u32 s
 	.get_sset_count    = cdc_ncm_get_sset_count,
 	.get_strings       = cdc_ncm_get_strings,
 	.get_ethtool_stats = cdc_ncm_get_ethtool_stats,
+	.get_link_ksettings      = usbnet_get_link_ksettings,
+	.set_link_ksettings      = usbnet_set_link_ksettings,
 };
 
 static u32 cdc_ncm_check_rx_max(struct usbnet *dev, u32 new_rx)
-- 
1.7.4.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
