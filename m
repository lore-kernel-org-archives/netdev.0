From: "Alex Bounine" <alex.bou9@gmail.com>
Subject: [PATCH 3/5 v3] Tsi108_eth: remove not needed code
Date: Mon, 11 Feb 2008 14:35:49 -0500
Message-ID: <d5f62df20802111135q36e47070w611291b2cea2253e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, tie-fei.zang@freescale.com,
	jwboyer@linux.vnet.ibm.com
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.191]:44806 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756190AbYBKTfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 14:35:50 -0500
Received: by rv-out-0910.google.com with SMTP id k20so3459745rvb.1
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 11:35:50 -0800 (PST)
Content-Disposition: inline
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
--- linux-2.6.24/drivers/net/tsi108_eth.c	2008-02-06 15:47:35.000000000 -0500
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
