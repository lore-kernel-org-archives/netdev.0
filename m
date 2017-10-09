From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH v3 net-next 04/12] qed: Fix initialization of ll2 offload feature
Date: Mon, 9 Oct 2017 12:37:46 +0300
Message-ID: <1507541874-18344-5-git-send-email-Michal.Kalderon@cavium.com>
References: <1507541874-18344-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        "Ariel Elior" <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0047.outbound.protection.outlook.com ([104.47.32.47]:25976
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751184AbdJIJii (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 05:38:38 -0400
In-Reply-To: <1507541874-18344-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enable_ip_cksum, enable_l4_cksum, calc_ip_len were added in
commit stated below but not passed through to FW. This was OK
until now as it wasn't used, but is required for the iWARP
unaligned flow

Fixes:7c7973b2ae27 ("qed: LL2 to use packed information for tx")

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index ad67d36..6d14474 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -1621,6 +1621,9 @@ static void qed_ll2_prepare_tx_packet_set(struct qed_hwfn *p_hwfn,
 	SET_FIELD(bd_data, CORE_TX_BD_DATA_START_BD, 0x1);
 	SET_FIELD(bd_data, CORE_TX_BD_DATA_NBDS, pkt->num_of_bds);
 	SET_FIELD(bd_data, CORE_TX_BD_DATA_ROCE_FLAV, roce_flavor);
+	SET_FIELD(bd_data, CORE_TX_BD_DATA_IP_CSUM, !!(pkt->enable_ip_cksum));
+	SET_FIELD(bd_data, CORE_TX_BD_DATA_L4_CSUM, !!(pkt->enable_l4_cksum));
+	SET_FIELD(bd_data, CORE_TX_BD_DATA_IP_LEN, !!(pkt->calc_ip_len));
 	start_bd->bd_data.as_bitfield = cpu_to_le16(bd_data);
 	DMA_REGPAIR_LE(start_bd->addr, pkt->first_frag);
 	start_bd->nbytes = cpu_to_le16(pkt->first_frag_len);
-- 
1.8.3.1
