From: Ingo Oeser <netdev@axxeo.de>
Subject: [PATCH] natsemi: Messages being noisy
Date: Wed, 13 Sep 2006 15:28:51 +0200
Message-ID: <200609131528.51336.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:16579 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1750801AbWIMN25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 09:28:57 -0400
To: Tim Hockin <thockin@hockin.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

I  get the following message when trying to transfer big files 
(via FTP or SCP) since Linux 2.6.16.27. It didn't happen with Linux 2.6.13.4.

[702238.242237] eth1: increased tx threshold, txcfg 0xd0f01008.
[702238.242649] eth1: increased tx threshold, txcfg 0xd0f0100a.

What about putting this message at the message level "DEBUG"
or even under pr_debug()?

This NIC is just used for PPPoE in our setups.

The other message "tx underrun with maximum tx threshold"
is much more useful, since it indicates a real problem.

So I would suggest the following patch:

Signed-off-by: Ingo Oeser <netdev@axxeo.de>

--- linux-2.6.16.28/drivers/net/natsemi.c~	2006-08-25 22:51:14.000000000 +0200
+++ linux-2.6.16.28/drivers/net/natsemi.c	2006-09-13 15:26:24.995044665 +0200
@@ -2338,8 +2338,7 @@
 		if ((np->tx_config & TxDrthMask) < TX_DRTH_VAL_LIMIT) {
 			np->tx_config += TX_DRTH_VAL_INC;
 			if (netif_msg_tx_err(np))
-				printk(KERN_NOTICE
-					"%s: increased tx threshold, txcfg %#08x.\n",
+				pr_debug("%s: increased tx threshold, txcfg %#08x.\n",
 					dev->name, np->tx_config);
 		} else {
 			if (netif_msg_tx_err(np))
