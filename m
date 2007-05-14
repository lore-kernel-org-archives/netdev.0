From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 2/2] s2io: add PCI error recovery support
Date: Mon, 14 May 2007 18:41:41 -0500
Message-ID: <20070514234141.GB4511@austin.ibm.com>
References: <20070514233730.GA4511@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	James.Bottomley@SteelEye.com, linux-kernel@vger.kernel.org,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:41618 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754462AbXENXlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 19:41:47 -0400
Content-Disposition: inline
In-Reply-To: <20070514233730.GA4511@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


s2io cleanup suggestions, per discussion on mailing lists.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/s2io.c |    2 --
 drivers/net/s2io.h |    1 -
 2 files changed, 3 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/s2io.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/s2io.c	2007-05-14 17:23:45.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/s2io.c	2007-05-14 17:24:03.000000000 -0500
@@ -3980,7 +3980,6 @@ static int s2io_close(struct net_device 
 	/* Reset card, kill tasklet and free Tx and Rx buffers. */
 	s2io_card_down(sp);
 
-	sp->device_close_flag = TRUE;	/* Device is shut down. */
 	return 0;
 }
 
@@ -8063,7 +8062,6 @@ static pci_ers_result_t s2io_io_error_de
 	if (netif_running(netdev)) {
 		/* Bring down the card, while avoiding PCI I/O */
 		do_s2io_card_down(sp, 0);
-		sp->device_close_flag = TRUE;	/* Device is shut down. */
 	}
 	pci_disable_device(pdev);
 
Index: linux-2.6.22-rc1/drivers/net/s2io.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/s2io.h	2007-05-14 17:23:45.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/s2io.h	2007-05-14 17:24:03.000000000 -0500
@@ -794,7 +794,6 @@ struct s2io_nic {
 
 	struct net_device_stats stats;
 	int high_dma_flag;
-	int device_close_flag;
 	int device_enabled_once;
 
 	char name[60];
