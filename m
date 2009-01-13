From: Daniele Venzano <venza@brownhat.org>
Subject: [PATCH] SIS900 show warning if bogus MAC address (take 2)
Date: Tue, 13 Jan 2009 19:18:21 +0100
Message-ID: <20090113181821.GA21342@milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="lrZ03NoBR/3+SXJZ"
Cc: akpm@linux-foundation.org, venza@brownhat.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.infomaniak.ch ([84.16.68.89]:52845 "EHLO
	smtp1.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353AbZAMSSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 13:18:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The attached patch modifies the sis900 driver when the MAC address
read from the hardware is invalid. As suggested, the patch now
generates a random address so that the user can go on and use
the hardware. In any case a message is also shown to warn on the
unexpected condition.
This seems to happen with newer HW implementation of the sis900
chipset, since this never came up before.

Patch is against vanilla 2.6.28 (but the driver doesn't change so often,
so it will probably apply to older/newer versions too).

See bugzilla ID 10201 and 11649 and ignore the previous patch.

Signed-off-by: Daniele Venzano <venza@brownhat.org>

--
Daniele Venzano
http://www.brownhat.org


--lrZ03NoBR/3+SXJZ
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="sis900_check_set_mac.diff"

--- a/drivers/net/sis900.c	2009-01-13 15:12:35.000000000 +0100
+++ b/drivers/net/sis900.c	2009-01-13 15:38:05.000000000 +0100
@@ -504,10 +504,10 @@ static int __devinit sis900_probe(struct
 	else
 		ret = sis900_get_mac_addr(pci_dev, net_dev);
 
-	if (ret == 0) {
-		printk(KERN_WARNING "%s: Cannot read MAC address.\n", dev_name);
-		ret = -ENODEV;
-		goto err_unmap_rx;
+	if (!ret || !is_valid_ether_addr(net_dev->dev_addr)) {
+		random_ether_addr(net_dev->dev_addr);
+		printk(KERN_WARNING "%s: Unreadable or invalid MAC address,"
+				"using random generated one\n", dev_name);
 	}
 
 	/* 630ET : set the mii access mode as software-mode */

--lrZ03NoBR/3+SXJZ--
