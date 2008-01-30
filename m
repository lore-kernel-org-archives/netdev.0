From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/sunbmac.c section fix
Date: Wed, 30 Jan 2008 22:03:34 +0200
Message-ID: <20080130200334.GM29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:37656 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759152AbYA3UDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:03:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following section mismatch:

<--  snip  -->

...
WARNING: drivers/net/sunbmac.o(.devinit.text+0x24): Section mismatch in reference from the function bigmac_sbus_probe() to the function .init.text:bigmac_ether_init()
...

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
c4238b1ec3c23ec9dbe8b4da932cfd381ef0f376 
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index fe3ac6f..0e4a88d 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -1075,7 +1075,7 @@ static const struct ethtool_ops bigmac_ethtool_ops = {
 	.get_link		= bigmac_get_link,
 };
 
-static int __init bigmac_ether_init(struct sbus_dev *qec_sdev)
+static int __devinit bigmac_ether_init(struct sbus_dev *qec_sdev)
 {
 	struct net_device *dev;
 	static int version_printed;

