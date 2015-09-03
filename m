From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] fixed_phy: pass 'irq' to fixed_phy_add()
Date: Thu, 03 Sep 2015 23:22:16 +0300
Message-ID: <3613326.r1qXWqo08b@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:34152 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbbICUWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 16:22:19 -0400
Received: by lbbmp1 with SMTP id mp1so526088lbb.1
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2015 13:22:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've noticed  that fixed_phy_register() ignores its 'irq' parameter instead of
passing it to fixed_phy_add(). Luckily, fixed_phy_register()  seems to  always
be  called with PHY_POLL  for 'irq'... :-)

Fixes: a75951217472 ("net: phy: extend fixed driver with fixed_phy_register()")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net.git' repo.

 drivers/net/phy/fixed_phy.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net/drivers/net/phy/fixed_phy.c
===================================================================
--- net.orig/drivers/net/phy/fixed_phy.c
+++ net/drivers/net/phy/fixed_phy.c
@@ -325,7 +325,7 @@ struct phy_device *fixed_phy_register(un
 	phy_addr = phy_fixed_addr++;
 	spin_unlock(&phy_fixed_addr_lock);
 
-	ret = fixed_phy_add(PHY_POLL, phy_addr, status, link_gpio);
+	ret = fixed_phy_add(irq, phy_addr, status, link_gpio);
 	if (ret < 0)
 		return ERR_PTR(ret);
 
