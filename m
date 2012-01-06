From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] usbnet: make ethtool_ops const
Date: Thu, 05 Jan 2012 21:10:23 -0800
Message-ID: <20120106051050.936477418@vyatta.com>
References: <20120106051022.712047093@vyatta.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Oliver Neukum <oliver@neukum.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:35081 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750910Ab2AFFQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 00:16:40 -0500
Content-Disposition: inline; filename=usb-ethtool-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool_ops table of function pointers should be const.
Fix all the usb network drivers.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Not sure if you want these through net-next or usb-next?

 drivers/net/usb/asix.c       |    2 +-
 drivers/net/usb/cdc_ncm.c    |    4 ++--
 drivers/net/usb/ipheth.c     |    2 +-
 drivers/net/usb/sierra_net.c |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

--- a/drivers/net/usb/asix.c	2011-12-23 21:06:15.724436897 -0800
+++ b/drivers/net/usb/asix.c	2012-01-04 14:12:38.832942290 -0800
@@ -1152,7 +1152,7 @@ static int ax88772_bind(struct usbnet *d
 	return 0;
 }
 
-static struct ethtool_ops ax88178_ethtool_ops = {
+static const struct ethtool_ops ax88178_ethtool_ops = {
 	.get_drvinfo		= asix_get_drvinfo,
 	.get_link		= asix_get_link,
 	.get_msglevel		= usbnet_get_msglevel,
--- a/drivers/net/usb/cdc_ncm.c	2011-12-07 10:54:18.960280313 -0800
+++ b/drivers/net/usb/cdc_ncm.c	2012-01-04 14:12:17.648667526 -0800
@@ -138,7 +138,7 @@ struct cdc_ncm_ctx {
 static void cdc_ncm_tx_timeout(unsigned long arg);
 static const struct driver_info cdc_ncm_info;
 static struct usb_driver cdc_ncm_driver;
-static struct ethtool_ops cdc_ncm_ethtool_ops;
+static const struct ethtool_ops cdc_ncm_ethtool_ops;
 
 static const struct usb_device_id cdc_devs[] = {
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM,
@@ -1220,7 +1220,7 @@ static struct usb_driver cdc_ncm_driver
 	.supports_autosuspend = 1,
 };
 
-static struct ethtool_ops cdc_ncm_ethtool_ops = {
+static const struct ethtool_ops cdc_ncm_ethtool_ops = {
 	.get_drvinfo = cdc_ncm_get_drvinfo,
 	.get_link = usbnet_get_link,
 	.get_msglevel = usbnet_get_msglevel,
--- a/drivers/net/usb/ipheth.c	2011-12-07 10:54:18.964280345 -0800
+++ b/drivers/net/usb/ipheth.c	2012-01-04 14:12:01.008460107 -0800
@@ -420,7 +420,7 @@ static u32 ipheth_ethtool_op_get_link(st
 	return netif_carrier_ok(dev->net);
 }
 
-static struct ethtool_ops ops = {
+static const struct ethtool_ops ops = {
 	.get_link = ipheth_ethtool_op_get_link
 };
 
--- a/drivers/net/usb/sierra_net.c	2011-12-07 10:54:18.968280377 -0800
+++ b/drivers/net/usb/sierra_net.c	2012-01-04 14:11:19.368146426 -0800
@@ -618,7 +618,7 @@ static u32 sierra_net_get_link(struct ne
 	return sierra_net_get_private(dev)->link_up && netif_running(net);
 }
 
-static struct ethtool_ops sierra_net_ethtool_ops = {
+static const struct ethtool_ops sierra_net_ethtool_ops = {
 	.get_drvinfo = sierra_net_get_drvinfo,
 	.get_link = sierra_net_get_link,
 	.get_msglevel = usbnet_get_msglevel,
