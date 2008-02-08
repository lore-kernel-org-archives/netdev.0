From: "Alexandre Bounine" <Alexandre.Bounine@tundra.com>
Subject: [PATCH 2/5] Tsi108_eth: fix detection of 1000Mb mode
Date: Fri, 8 Feb 2008 14:17:04 -0500
Message-ID: <1B5F013528140F45B5C671039279CA5702A960A0@NANUK.pc.tundra.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linuxppc-dev@ozlabs.org>,
	"Josh Boyer" <jwboyer@linux.vnet.ibm.com>,
	"Zang Roy-r61911" <tie-fei.zang@freescale.com>
To: <jgarzik@pobox.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.tundra.com ([142.46.200.162]:48745 "EHLO mx2.tundra.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763241AbYBHT3v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 14:29:51 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fix for tsi108_eth network driver.
This patch fixes a problem with detection of 1000Mb speed. 
   
Signed-off-by: Alexandre Bounine <alexandreb@tundra.com>
---

diff -pNur linux-2.6.24/drivers/net/tsi108_eth.c
linux-2.6.24-fix/drivers/net/tsi108_eth.c
--- linux-2.6.24/drivers/net/tsi108_eth.c	2008-02-06
15:09:19.000000000 -0500
+++ linux-2.6.24-fix/drivers/net/tsi108_eth.c	2008-02-06
15:34:12.000000000 -0500
@@ -1287,6 +1287,7 @@ static void tsi108_init_phy(struct net_d
 		spin_lock_irqsave(&phy_lock, flags);
 	}
 
+	data->mii_if.supports_gmii =
mii_check_gmii_support(&data->mii_if);
 	printk(KERN_DEBUG "PHY_STAT reg contains %08x\n", phyval);
 	data->phy_ok = 1;
 	data->init_media = 1;
@@ -1584,7 +1585,6 @@ tsi108_init_one(struct platform_device *
 	data->mii_if.phy_id = einfo->phy;
 	data->mii_if.phy_id_mask = 0x1f;
 	data->mii_if.reg_num_mask = 0x1f;
-	data->mii_if.supports_gmii =
mii_check_gmii_support(&data->mii_if);
 
 	data->phy = einfo->phy;
 	data->phy_type = einfo->phy_type;



---



Important Notice: This message is intended for the use of the individual to whom it is addressed and may contain information which is privileged, confidential and/or exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, or is not the employee or agent responsible for delivering the message to the intended recipient, you are hereby notified that any dissemination, distribution, or copying of this communication is strictly prohibited. If you have received this communication in error, please notify the sender immediately by telephone or return e-mail and delete the original message from your systems. Thank you. 


