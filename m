From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: remove rx_pkt/rx_calls
Date: Tue, 08 Dec 2015 10:28:30 -0800
Message-ID: <1449599310.6639.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <ariel.elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36240 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbbLHS2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 13:28:33 -0500
Received: by pfdd184 with SMTP id d184so15898690pfd.3
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 10:28:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

These fields are updated but never read.
Remove the overhead.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     |    2 --
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    4 ----
 2 files changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 0b214b5d944a..cae0956186ce 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -590,8 +590,6 @@ struct bnx2x_fastpath {
 	/* The last maximal completed SGE */
 	u16			last_max_sge;
 	__le16			*rx_cons_sb;
-	unsigned long		rx_pkt,
-				rx_calls;
 
 	/* TPA related */
 	struct bnx2x_agg_info	*tpa_info;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index f6634a524153..2c0d21918417 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1122,9 +1122,6 @@ next_cqe:
 	bnx2x_update_rx_prod(bp, fp, bd_prod_fw, sw_comp_prod,
 			     fp->rx_sge_prod);
 
-	fp->rx_pkt += rx_pkt;
-	fp->rx_calls++;
-
 	return rx_pkt;
 }
 
@@ -4442,7 +4439,6 @@ static int bnx2x_alloc_rx_bds(struct bnx2x_fastpath *fp,
 	/* Limit the CQE producer by the CQE ring size */
 	fp->rx_comp_prod = min_t(u16, NUM_RCQ_RINGS*RCQ_DESC_CNT,
 			       cqe_ring_prod);
-	fp->rx_pkt = fp->rx_calls = 0;
 
 	bnx2x_fp_stats(bp, fp)->eth_q_stats.rx_skb_alloc_failed += failure_cnt;
 
