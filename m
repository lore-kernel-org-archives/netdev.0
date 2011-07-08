From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] net/natsemi: Fix module parameter permissions
Date: Fri, 8 Jul 2011 11:01:28 +0200
Message-ID: <201107081101.28812.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tim Hockin <thockin@hockin.org>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53638 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754287Ab1GHJBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2011 05:01:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The third parameter of module_param is supposed to represent sysfs
file permissions. A value of "1" leads to the following:

$ ls -l /sys/module/natsemi/parameters/
total 0
---------x 1 root root 4096 Jul  8 09:46 dspcfg_workaround

I am changing it to "0" to align with the other module parameters in
this driver.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Tim Hockin <thockin@hockin.org>
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>
---
 drivers/net/natsemi.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-3.0-rc6.orig/drivers/net/natsemi.c	2011-05-30 20:45:13.000000000 +0200
+++ linux-3.0-rc6/drivers/net/natsemi.c	2011-07-08 09:57:47.000000000 +0200
@@ -140,7 +140,7 @@ MODULE_LICENSE("GPL");
 module_param(mtu, int, 0);
 module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
-module_param(dspcfg_workaround, int, 1);
+module_param(dspcfg_workaround, int, 0);
 module_param_array(options, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
 MODULE_PARM_DESC(mtu, "DP8381x MTU (all boards)");

-- 
Jean Delvare
Suse L3
