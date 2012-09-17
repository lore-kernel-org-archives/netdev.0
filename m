From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] ncm: allow for NULL terminations
Date: Mon, 17 Sep 2012 11:58:55 +0100
Message-ID: <20120917105853.30298.29234.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:32933 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440Ab2IQKkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 06:40:24 -0400
Received: from localhost.localdomain (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id q8HBCtXb000999
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 12:13:01 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

The strings are passed to snprintf so must be null terminated. It seems the
copy length is incorrectly set.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/usb/cdc_ncm.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4cd582a..af8cce7 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -145,10 +145,10 @@ cdc_ncm_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
 {
 	struct usbnet *dev = netdev_priv(net);
 
-	strncpy(info->driver, dev->driver_name, sizeof(info->driver));
-	strncpy(info->version, DRIVER_VERSION, sizeof(info->version));
+	strncpy(info->driver, dev->driver_name, sizeof(info->driver) - 1);
+	strncpy(info->version, DRIVER_VERSION, sizeof(info->version) - 1);
 	strncpy(info->fw_version, dev->driver_info->description,
-		sizeof(info->fw_version));
+		sizeof(info->fw_version) - 1);
 	usb_make_path(dev->udev, info->bus_info, sizeof(info->bus_info));
 }
 
