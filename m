From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH] DM9000 - check for MAC left in by bootloader
Date: Tue, 13 Jun 2006 23:50:15 +0100
Message-ID: <20060613225015.GA26795@home.fluff.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="EVF5PPMfhYS0aIcm"
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-84-9-203-241.bulldogdsl.com ([84.9.203.241]:9606 "EHLO
	aeryn.fluff.org.uk") by vger.kernel.org with ESMTP id S1751208AbWFMWug
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 18:50:36 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The DM9000 driver does not deal with the case
where there is no serial EEPROM to store the
configuration, and the bootloader has placed
an MAC address into the device already.

If there is no valid MAC in the EEPROM, read
the one already in the chip and check to see
if that one is valid.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dm9k-no-valid-eeprom.patch"

--- ../linux-2.6.17/linux-2.6.17-rc5/drivers/net/dm9000.c	2006-03-20 05:53:29.000000000 +0000
+++ linux-2.6.16-simtec2/drivers/net/dm9000.c	2006-05-22 21:46:18.000000000 +0100
@@ -564,6 +559,13 @@ dm9000_probe(struct platform_device *pde
 	for (i = 0; i < 6; i++)
 		ndev->dev_addr[i] = db->srom[i];
 
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
+		/* try reading from mac */
+
+		for (i = 0; i < 6; i++)
+			ndev->dev_addr[i] = ior(db, i+DM9000_PAR);
+	}
+
 	if (!is_valid_ether_addr(ndev->dev_addr))
 		printk("%s: Invalid ethernet MAC address.  Please "
 		       "set using ifconfig\n", ndev->name);

--EVF5PPMfhYS0aIcm--
