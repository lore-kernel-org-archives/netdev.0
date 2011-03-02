From: Roger Luethi <rl@hellgate.ch>
Subject: [PATCH] via-rhine: do not abort due to invalid MAC address
Date: Wed, 2 Mar 2011 17:32:33 +0100
Message-ID: <20110302163233.GA14491@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"Alex G." <mr.nuke.me@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail14.bluewin.ch ([195.186.19.62]:20180 "EHLO
	mail14.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611Ab1CBQje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 11:39:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alex G." <mr.nuke.me@gmail.com>

via-rhine drops out of the init code if the hardware provides an invalid
MAC address. I have several reports of Rhine NICs doing just that. The
hardware still works, though; continuing the init process gives the user a
chance to fix the MAC address using "ifconfig ethX hw ether" which appears
to result in a perfectly useable network adapter.

Most recent report and patch provided by Alex G.

Signed-off-by: "Alex G." <mr.nuke.me@gmail.com>
Signed-off-by: Roger Luethi <rl@hellgate.ch>

diff --git a/linux-2.6.35.11/drivers/net/via-rhine.c b/via-rhine.c
index 4930f9d..a1189f4 100644
--- a/linux-2.6.35.11/drivers/net/via-rhine.c
+++ b/via-rhine.c
@@ -766,8 +766,12 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 
 	if (!is_valid_ether_addr(dev->perm_addr)) {
 		rc = -EIO;
-		printk(KERN_ERR "Invalid MAC address\n");
-		goto err_out_unmap;
+		printk(KERN_ERR "via-rhine: invalid MAC address: %pM. "
+				"Use ifconfig to configure valid address.\n",
+				dev->dev_addr);
+		/* The device may still be used normally if a valid MAC is configured
+		 * We do not consider this a fatal error, and continue initialization
+		 */
 	}
 
 	/* For Rhine-I/II, phy_id is loaded from EEPROM */
