From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: smc91x: constify dev_pm_ops structures.
Date: Thu, 29 Jun 2017 11:21:00 +0530
Message-ID: <f588f3a825cfb2bbdee2f53d9b7d470b0db8f968.1498715281.git.arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, rmk+kernel@armlinux.org.uk,
        jeremy.linton@arm.com, jarod@redhat.com, nico@fluxnic.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33634 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751613AbdF2Fvw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 01:51:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_pm_ops are not supposed to change at runtime. All functions
working with dev_pm_ops provided by <linux/device.h> work with const
dev_pm_ops. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
  18709	    401	      0	  19110	   4aa6	drivers/net/ethernet/smsc/smc91x.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  18901	    201	      0	  19102	   4a9e	drivers/net/ethernet/smsc/smc91x.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/smsc/smc91x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 91e9bd7..83cf052 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2488,7 +2488,7 @@ static int smc_drv_resume(struct device *dev)
 	return 0;
 }
 
-static struct dev_pm_ops smc_drv_pm_ops = {
+static const struct dev_pm_ops smc_drv_pm_ops = {
 	.suspend	= smc_drv_suspend,
 	.resume		= smc_drv_resume,
 };
-- 
1.9.1
