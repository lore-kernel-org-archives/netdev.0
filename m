From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/5] skge: dont allow bad hardware address from ROM
Date: Tue, 06 Jun 2006 10:11:14 -0700
Message-ID: <20060606171342.334413000@zqx3.pdx.osdl.net>
References: <20060606171110.592587000@zqx3.pdx.osdl.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52946 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750889AbWFFROo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 13:14:44 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-badaddr.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sometimes boards don't reset properly, and the address read out of the
EEPROM is zero. Stop the insanity before the device gets registered.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -3362,6 +3362,14 @@ static int __devinit skge_probe(struct p
 	if ((dev = skge_devinit(hw, 0, using_dac)) == NULL)
 		goto err_out_led_off;
 
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		printk(KERN_ERR PFX "%s: bad (zero?) ethernet address in rom\n",
+		       pci_name(pdev));
+		err = -EIO;
+		goto err_out_free_netdev;
+	}
+
+
 	err = register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR PFX "%s: cannot register net device\n",

--

