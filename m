From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: PROBLEM: freeze when resuming from suspend-to-ram
Date: Sat, 17 Nov 2012 20:20:36 +0100
Message-ID: <20121117192036.GA29018@electric-eye.fr.zoreil.com>
References: <1560844.T75lq5MbC7@brinja> <20121114211115.GD14880@ge.brownhat.org> <20121117105702.GA25549@electric-eye.fr.zoreil.com> <2582926.dI8WEMfVKW@brinja>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniele Venzano <venza@brownhat.org>, netdev@vger.kernel.org
To: Jan Janssen <medhefgo@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57433 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060Ab2KQTn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 14:43:57 -0500
Content-Disposition: inline
In-Reply-To: <2582926.dI8WEMfVKW@brinja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Janssen <medhefgo@web.de> :
[...]
> I'd be glad to help you with that. The bug happens with 3.6.6 and with 3.7-
> rc6. Pick one that suits you best, I can work with both.

/me slaps head.

Please try the patch below against v3.7-rc6

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index fb9f6b3..edf5edb 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -2479,7 +2479,7 @@ static int sis900_resume(struct pci_dev *pci_dev)
 	netif_start_queue(net_dev);
 
 	/* Workaround for EDB */
-	sis900_set_mode(ioaddr, HW_SPEED_10_MBPS, FDX_CAPABLE_HALF_SELECTED);
+	sis900_set_mode(sis_priv, HW_SPEED_10_MBPS, FDX_CAPABLE_HALF_SELECTED);
 
 	/* Enable all known interrupts by setting the interrupt mask. */
 	sw32(imr, RxSOVR | RxORN | RxERR | RxOK | TxURN | TxERR | TxIDLE);
