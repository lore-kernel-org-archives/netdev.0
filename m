From: "George G. Davis" <gdavis@mvista.com>
Subject: [PATCH] Fix an offset error when reading the CS89x0 ADD_PORT register
Date: Thu, 16 Nov 2006 14:50:14 -0500
Message-ID: <20061116195014.GB28540@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from homer.mvista.com ([63.81.120.158]:28084 "EHLO
	gateway-1237.mvista.com") by vger.kernel.org with ESMTP
	id S1424268AbWKPTuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 14:50:15 -0500
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix an offset error when reading the CS89x0 ADD_PORT register.

Signed-off-by: George G. Davis
---

Index: linux-2.6/drivers/net/cs89x0.c
===================================================================
--- linux-2.6.orig/drivers/net/cs89x0.c
+++ linux-2.6/drivers/net/cs89x0.c
@@ -588,10 +588,10 @@ cs89x0_probe1(struct net_device *dev, in
 				goto out2;
 			}
 	}
-	printk(KERN_DEBUG "PP_addr at %x[%x]: 0x%x\n",
-			ioaddr, ADD_PORT, readword(ioaddr, ADD_PORT));
 
 	ioaddr &= ~3;
+	printk(KERN_DEBUG "PP_addr at %x[%x]: 0x%x\n",
+			ioaddr, ADD_PORT, readword(ioaddr, ADD_PORT));
 	writeword(ioaddr, ADD_PORT, PP_ChipID);
 
 	tmp = readword(ioaddr, DATA_PORT);
