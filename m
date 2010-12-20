From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] typhoon: memory corruption in typhoon_get_drvinfo()
Date: Mon, 20 Dec 2010 16:00:18 +0300
Message-ID: <20101220130018.GX1936@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48503 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750Ab0LTNAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 08:00:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

info->version only has space for 32 characters but my UTS_RELEASE is
"2.6.37-rc6-next-20101217-05817-ge935fc8-dirty" so it doesn't fit.
This is supposed to be the version of the driver, not the kernel
version.  This driver doesn't have a version so lets just leave it
blank.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
Found with static analysis.  Compile tested.

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 5b83c3f..a3c46f6 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1004,7 +1004,6 @@ typhoon_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	}
 
 	strcpy(info->driver, KBUILD_MODNAME);
-	strcpy(info->version, UTS_RELEASE);
 	strcpy(info->bus_info, pci_name(pci_dev));
 }
 
