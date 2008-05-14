From: akpm@linux-foundation.org
Subject: [patch 1/8] iphase: fix 64bit warning
Date: Wed, 14 May 2008 16:19:39 -0700
Message-ID: <200805142319.m4ENJdEQ026549@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, alan@redhat.com, chas@cmf.nrl.navy.mil,
	jeff@garzik.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49121 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753199AbYENXUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:20:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>

Time is unsigned long (except when you are in a hurry) so we need to store
rx_tmp_jif in the right sized object.

Signed-off-by: Alan Cox <alan@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: chas williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/iphase.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/atm/iphase.h~iphase-fix-64bit-warning drivers/atm/iphase.h
--- a/drivers/atm/iphase.h~iphase-fix-64bit-warning
+++ a/drivers/atm/iphase.h
@@ -1025,7 +1025,8 @@ typedef struct iadev_t {  
         spinlock_t rx_lock, misc_lock;
 	struct atm_vcc **rx_open;	/* list of all open VCs */  
         u16 num_rx_desc, rx_buf_sz, rxing;
-        u32 rx_pkt_ram, rx_tmp_cnt, rx_tmp_jif;
+        u32 rx_pkt_ram, rx_tmp_cnt;
+        unsigned long rx_tmp_jif;
         void __iomem *RX_DESC_BASE_ADDR;
         u32 drop_rxpkt, drop_rxcell, rx_cell_cnt, rx_pkt_cnt;
 	struct atm_dev *next_board;	/* other iphase devices */  
_
