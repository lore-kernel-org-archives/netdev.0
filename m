From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] iphase: Fix 64bit warning
Date: Fri, 2 May 2008 14:20:34 +0100
Message-ID: <20080502142034.6505e72f@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:50599 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764283AbYEBN2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 09:28:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Time is unsigned long (except when you are in a hurry) so we need to store
rx_tmp_jif in the right sized object.

Signed-off-by: Alan Cox <alan@redhat.com>

diff -u --new-file --recursive --exclude-from /usr/src/exclude linux.vanilla-2.6.25-mm1/drivers/atm/iphase.h linux-2.6.25-mm1/drivers/atm/iphase.h
--- linux.vanilla-2.6.25-mm1/drivers/atm/iphase.h	2008-04-28 11:35:43.000000000 +0100
+++ linux-2.6.25-mm1/drivers/atm/iphase.h	2008-05-02 14:16:27.000000000 +0100
@@ -1025,7 +1025,8 @@
         spinlock_t rx_lock, misc_lock;
 	struct atm_vcc **rx_open;	/* list of all open VCs */  
         u16 num_rx_desc, rx_buf_sz, rxing;
-        u32 rx_pkt_ram, rx_tmp_cnt, rx_tmp_jif;
+        u32 rx_pkt_ram, rx_tmp_cnt;
+        unsigned long rx_tmp_jif;
         void __iomem *RX_DESC_BASE_ADDR;
         u32 drop_rxpkt, drop_rxcell, rx_cell_cnt, rx_pkt_cnt;
 	struct atm_dev *next_board;	/* other iphase devices */  
