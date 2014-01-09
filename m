From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH v4 1/5] alx: add a hardware stats structure
Date: Thu,  9 Jan 2014 10:09:27 +0100
Message-ID: <1389258571-10083-2-git-send-email-sd@queasysnail.net>
References: <1389258571-10083-1-git-send-email-sd@queasysnail.net>
Cc: bhutchings@solarflare.com, johannes@sipsolutions.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:47449 "EHLO
	smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754772AbaAIJKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 04:10:47 -0500
Received: from smtp5-g21.free.fr (smtp5-g21.free.fr [212.27.42.5])
	by smtpfb2-g21.free.fr (Postfix) with ESMTP id 94F4FCDBDE0
	for <netdev@vger.kernel.org>; Thu,  9 Jan 2014 10:10:43 +0100 (CET)
In-Reply-To: <1389258571-10083-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ethernet/atheros/alx/hw.h | 62 +++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)

diff --git a/drivers/net/ethernet/atheros/alx/hw.h b/drivers/net/ethernet/atheros/alx/hw.h
index 96f3b43..872b362 100644
--- a/drivers/net/ethernet/atheros/alx/hw.h
+++ b/drivers/net/ethernet/atheros/alx/hw.h
@@ -381,6 +381,68 @@ struct alx_rrd {
 				 ALX_ISR_RX_Q6 | \
 				 ALX_ISR_RX_Q7)
 
+/* Statistics counters collected by the MAC */
+struct alx_hw_stats {
+	/* rx */
+	u64 rx_ok;		/* good RX packets */
+	u64 rx_bcast;		/* good RX broadcast packets */
+	u64 rx_mcast;		/* good RX multicast packets */
+	u64 rx_pause;		/* RX pause frames */
+	u64 rx_ctrl;		/* RX control packets other than pause frames */
+	u64 rx_fcs_err;		/* RX packets with bad FCS */
+	u64 rx_len_err;		/* RX packets with length != actual size */
+	u64 rx_byte_cnt;	/* good bytes received. FCS is NOT included */
+	u64 rx_runt;		/* RX packets < 64 bytes with good FCS */
+	u64 rx_frag;		/* RX packets < 64 bytes with bad FCS */
+	u64 rx_sz_64B;		/* 64 byte RX packets */
+	u64 rx_sz_127B;		/* 65-127 byte RX packets */
+	u64 rx_sz_255B;		/* 128-255 byte RX packets */
+	u64 rx_sz_511B;		/* 256-511 byte RX packets */
+	u64 rx_sz_1023B;	/* 512-1023 byte RX packets */
+	u64 rx_sz_1518B;	/* 1024-1518 byte RX packets */
+	u64 rx_sz_max;		/* 1519 byte to MTU RX packets */
+	u64 rx_ov_sz;		/* truncated RX packets, size > MTU */
+	u64 rx_ov_rxf;		/* frames dropped due to RX FIFO overflow */
+	u64 rx_ov_rrd;		/* frames dropped due to RRD overflow */
+	u64 rx_align_err;	/* alignment errors */
+	u64 rx_bc_byte_cnt;	/* RX broadcast bytes, excluding FCS */
+	u64 rx_mc_byte_cnt;	/* RX multicast bytes, excluding FCS */
+	u64 rx_err_addr;	/* packets dropped due to address filtering */
+
+	/* tx */
+	u64 tx_ok;		/* good TX packets */
+	u64 tx_bcast;		/* good TX broadcast packets */
+	u64 tx_mcast;		/* good TX multicast packets */
+	u64 tx_pause;		/* TX pause frames */
+	u64 tx_exc_defer;	/* TX packets deferred excessively */
+	u64 tx_ctrl;		/* TX control frames, excluding pause frames */
+	u64 tx_defer;		/* TX packets deferred */
+	u64 tx_byte_cnt;	/* bytes transmitted, FCS is NOT included */
+	u64 tx_sz_64B;		/* 64 byte TX packets */
+	u64 tx_sz_127B;		/* 65-127 byte TX packets */
+	u64 tx_sz_255B;		/* 128-255 byte TX packets */
+	u64 tx_sz_511B;		/* 256-511 byte TX packets */
+	u64 tx_sz_1023B;	/* 512-1023 byte TX packets */
+	u64 tx_sz_1518B;	/* 1024-1518 byte TX packets */
+	u64 tx_sz_max;		/* 1519 byte to MTU TX packets */
+	u64 tx_single_col;	/* packets TX after a single collision */
+	u64 tx_multi_col;	/* packets TX after multiple collisions */
+	u64 tx_late_col;	/* TX packets with late collisions */
+	u64 tx_abort_col;	/* TX packets aborted w/excessive collisions */
+	u64 tx_underrun;	/* TX packets aborted due to TX FIFO underrun
+				 * or TRD FIFO underrun
+				 */
+	u64 tx_trd_eop;		/* reads beyond the EOP into the next frame
+				 * when TRD was not written timely
+				 */
+	u64 tx_len_err;		/* TX packets where length != actual size */
+	u64 tx_trunc;		/* TX packets truncated due to size > MTU */
+	u64 tx_bc_byte_cnt;	/* broadcast bytes transmitted, excluding FCS */
+	u64 tx_mc_byte_cnt;	/* multicast bytes transmitted, excluding FCS */
+	u64 update;
+};
+
+
 /* maximum interrupt vectors for msix */
 #define ALX_MAX_MSIX_INTRS	16
 
-- 
1.8.5.2
