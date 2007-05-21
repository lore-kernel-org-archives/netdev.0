From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 2/2]: s2io: minor janitoring
Date: Mon, 21 May 2007 14:02:18 -0500
Message-ID: <20070521190218.GE5921@austin.ibm.com>
References: <20070521185853.GD5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:60810 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761833AbXEUTCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 15:02:21 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4LJ2KMF009302
	for <netdev@vger.kernel.org>; Mon, 21 May 2007 15:02:20 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4LJ2JE2261616
	for <netdev@vger.kernel.org>; Mon, 21 May 2007 13:02:19 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4LJ2Ivk015036
	for <netdev@vger.kernel.org>; Mon, 21 May 2007 13:02:19 -0600
Content-Disposition: inline
In-Reply-To: <20070521185853.GD5921@austin.ibm.com>
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
--- linux-2.6.22-rc1.orig/drivers/net/s2io.c	2007-05-21 13:32:45.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/s2io.c	2007-05-21 13:33:18.000000000 -0500
@@ -3980,7 +3980,6 @@ static int s2io_close(struct net_device 
 	/* Reset card, kill tasklet and free Tx and Rx buffers. */
 	s2io_card_down(sp);
 
-	sp->device_close_flag = TRUE;	/* Device is shut down. */
 	return 0;
 }
 
@@ -8075,7 +8074,6 @@ static pci_ers_result_t s2io_io_error_de
 	if (netif_running(netdev)) {
 		/* Bring down the card, while avoiding PCI I/O */
 		do_s2io_card_down(sp, 0);
-		sp->device_close_flag = TRUE;	/* Device is shut down. */
 	}
 	pci_disable_device(pdev);
 
Index: linux-2.6.22-rc1/drivers/net/s2io.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/s2io.h	2007-05-21 11:54:52.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/s2io.h	2007-05-21 13:33:18.000000000 -0500
@@ -794,7 +794,6 @@ struct s2io_nic {
 
 	struct net_device_stats stats;
 	int high_dma_flag;
-	int device_close_flag;
 	int device_enabled_once;
 
 	char name[60];
