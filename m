From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: [PATCH] atl1: remove write-only var in tx handler
Date: Fri, 6 Jul 2007 19:05:25 +0400
Message-ID: <20070706150525.GD11067@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, csnook@redhat.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:3067 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754207AbXGFPGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 11:06:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
---

 drivers/net/atl1/atl1_main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -634,14 +634,13 @@ static void atl1_intr_tx(struct atl1_adapter *adapter)
 	struct atl1_buffer *buffer_info;
 	u16 sw_tpd_next_to_clean;
 	u16 cmb_tpd_next_to_clean;
-	u8 update = 0;
 
 	sw_tpd_next_to_clean = atomic_read(&tpd_ring->next_to_clean);
 	cmb_tpd_next_to_clean = le16_to_cpu(adapter->cmb.cmb->tpd_cons_idx);
 
 	while (cmb_tpd_next_to_clean != sw_tpd_next_to_clean) {
 		struct tx_packet_desc *tpd;
-		update = 1;
+
 		tpd = ATL1_TPD_DESC(tpd_ring, sw_tpd_next_to_clean);
 		buffer_info = &tpd_ring->buffer_info[sw_tpd_next_to_clean];
 		if (buffer_info->dma) {

