From: Tom D'Alba <tomster595@gmail.com>
Subject: [PATCH net-next] jazzsonic: printk() style fixes
Date: Thu, 24 Oct 2013 21:39:40 +0000
Message-ID: <1382650780-24114-1-git-send-email-tomster595@gmail.com>
Cc: Tom D'Alba <dalbat@rpi.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:63200 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090Ab3JXVjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 17:39:46 -0400
Received: by mail-qa0-f42.google.com with SMTP id w8so115845qac.8
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 14:39:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom D'Alba <dalbat@rpi.edu>

Fixed printk() format by adding correct KERN_ statuses.

Reviewed-by: Nicholas Guthrie <nickg4317@gmail.com>
Reviewed-by: Sarah Williams <swilliams704@gmail.com>
Reviewed-by: Jason Lee <calccrypto@gmail.com>
Signed-off-by: Tom D'Alba <dalbat@rpi.edu>
---
 drivers/net/ethernet/natsemi/jazzsonic.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
index 79257f7..3a04d32 100644
--- a/drivers/net/ethernet/natsemi/jazzsonic.c
+++ b/drivers/net/ethernet/natsemi/jazzsonic.c
@@ -135,7 +135,7 @@ static int sonic_probe1(struct net_device *dev)
 	 */
 	silicon_revision = SONIC_READ(SONIC_SR);
 	if (sonic_debug > 1)
-		printk("SONIC Silicon Revision = 0x%04x\n",silicon_revision);
+	  printk(KERN_INFO "SONIC Silicon Revision = 0x%04x\n",silicon_revision);
 
 	i = 0;
 	while (known_revisions[i] != 0xffff &&
@@ -143,13 +143,13 @@ static int sonic_probe1(struct net_device *dev)
 		i++;
 
 	if (known_revisions[i] == 0xffff) {
-		printk("SONIC ethernet controller not found (0x%4x)\n",
+		printk(KERN_ERR "SONIC ethernet controller not found (0x%4x)\n",
 		       silicon_revision);
 		goto out;
 	}
 
 	if (sonic_debug  &&  version_printed++ == 0)
-		printk(version);
+	      printk(KERN_INFO version);
 
 	printk(KERN_INFO "%s: Sonic ethernet found at 0x%08lx, ",
 	       dev_name(lp->device), dev->base_addr);
-- 
1.8.1.2
