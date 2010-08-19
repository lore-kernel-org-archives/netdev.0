From: Dan Carpenter <error27@gmail.com>
Subject: [patch] tokenring: remove unneeded NULL checks
Date: Thu, 19 Aug 2010 12:04:38 +0200
Message-ID: <20100819100438.GC6674@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64295 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949Ab0HSKE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 06:04:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"fw_entry" is always non-NULL at this point and anyway
release_firmware() handles NULL parameters.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index 435ef7d..08182fd 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -1321,14 +1321,12 @@ static int tms380tr_reset_adapter(struct net_device *dev)
 
 			/* Clear CPHALT and start BUD */
 			SIFWRITEW(c, SIFACL);
-			if (fw_entry)
-				release_firmware(fw_entry);
+			release_firmware(fw_entry);
 			return (1);
 		}
 	} while(count == 0);
 
-	if (fw_entry)
-		release_firmware(fw_entry);
+	release_firmware(fw_entry);
 	printk(KERN_INFO "%s: Adapter Download Failed\n", dev->name);
 	return (-1);
 }
