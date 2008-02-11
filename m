From: "Alexandre Bounine" <Alexandre.Bounine@tundra.com>
Subject: [PATCH 3/5 v2] Tsi108_eth: remove not needed code
Date: Mon, 11 Feb 2008 11:32:11 -0500
Message-ID: <1B5F013528140F45B5C671039279CA5702A9638D@NANUK.pc.tundra.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linuxppc-dev@ozlabs.org>,
	"Josh Boyer" <jwboyer@linux.vnet.ibm.com>,
	"Zang Roy-r61911" <tie-fei.zang@freescale.com>
To: <jgarzik@pobox.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.tundra.com ([142.46.200.162]:54449 "EHLO mx2.tundra.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756222AbYBKQcN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 11:32:13 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code clean-up for tsi108_eth network driver.
This patch removes not needed dummy read and the corresponding comment.
The PHY logic requires two reads from the status register to get 
current link status. This is done correctly inside mii_check_media().  
   
Signed-off-by: Alexandre Bounine <alexandreb@tundra.com>
---

diff -pNur linux-2.6.24/drivers/net/tsi108_eth.c
linux-2.6.24-fix/drivers/net/tsi108_eth.c
--- linux-2.6.24/drivers/net/tsi108_eth.c	2008-02-06
15:47:35.000000000 -0500
+++ linux-2.6.24-fix/drivers/net/tsi108_eth.c	2008-02-06
15:54:14.000000000 -0500
@@ -297,18 +297,11 @@ static void tsi108_check_phy(struct net_
 	u32 speed;
 	unsigned long flags;
 
-	/* Do a dummy read, as for some reason the first read
-	 * after a link becomes up returns link down, even if
-	 * it's been a while since the link came up.
-	 */
-
 	spin_lock_irqsave(&phy_lock, flags);
 
 	if (!data->phy_ok)
 		goto out;
 
-	tsi108_read_mii(data, MII_BMSR);
-
 	duplex = mii_check_media(&data->mii_if, netif_msg_link(data),
data->init_media);
 	data->init_media = 0;


---



Important Notice: This message is intended for the use of the individual to whom it is addressed and may contain information which is privileged, confidential and/or exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, or is not the employee or agent responsible for delivering the message to the intended recipient, you are hereby notified that any dissemination, distribution, or copying of this communication is strictly prohibited. If you have received this communication in error, please notify the sender immediately by telephone or return e-mail and delete the original message from your systems. Thank you. 


