From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-2.6 6/7] atm: [he] limit queries to the device's register space
Date: Mon, 16 Jun 2008 13:27:50 -0400
Message-ID: <200806161727.m5GHRo6N003390@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:45520 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125AbYFPR15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 13:27:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 75e7637e840b7b3ec97df6e04357d607a2aee077
Author: "Robert T. Johnson" <rtjohnso@eecs.berkeley.edu>
Date:   Sat Jun 14 17:40:16 2008 -0400

    atm: [he] limit queries to the device's register space
    
    From: "Robert T. Johnson" <rtjohnso@eecs.berkeley.edu>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 88034d9..cd58cd3 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2693,10 +2693,15 @@ he_ioctl(struct atm_dev *atm_dev, unsigned int cmd, void __user *arg)
 			if (copy_from_user(&reg, arg,
 					   sizeof(struct he_ioctl_reg)))
 				return -EFAULT;
-			
+
 			spin_lock_irqsave(&he_dev->global_lock, flags);
 			switch (reg.type) {
 				case HE_REGTYPE_PCI:
+					if (reg.addr < 0 || reg.addr >= HE_REGMAP_SIZE) {
+						err = -EINVAL;
+						break;
+					}
+					
 					reg.val = he_readl(he_dev, reg.addr);
 					break;
 				case HE_REGTYPE_RCM:
