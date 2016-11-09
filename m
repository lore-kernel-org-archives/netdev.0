From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 1/2] qed: configure ll2 RoCE v1/v2 flavor correctly
Date: Wed, 9 Nov 2016 22:48:43 +0200
Message-ID: <1478724524-16940-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1478724524-16940-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1478724524-16940-1-git-send-email-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Currently RoCE v2 won't operate with RDMA CM due to missing setting of
the roce-flavour in the ll2 configuration.
This patch properly sets the flavour, and deletes incorrect HSI
that doesn't [yet] exist.

Fixes: abd49676c707 ("qed: Add RoCE ll2 & GSI support")
Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_hsi.h | 3 ---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 1 +
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 72eee29..2777d5b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -727,9 +727,6 @@ struct core_tx_bd_flags {
 #define CORE_TX_BD_FLAGS_L4_PROTOCOL_SHIFT	6
 #define CORE_TX_BD_FLAGS_L4_PSEUDO_CSUM_MODE_MASK	0x1
 #define CORE_TX_BD_FLAGS_L4_PSEUDO_CSUM_MODE_SHIFT 7
-#define CORE_TX_BD_FLAGS_ROCE_FLAV_MASK		0x1
-#define CORE_TX_BD_FLAGS_ROCE_FLAV_SHIFT	12
-
 };
 
 struct core_tx_bd {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 63e1a1b..f95385c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -1119,6 +1119,7 @@ static void qed_ll2_prepare_tx_packet_set_bd(struct qed_hwfn *p_hwfn,
 	start_bd->bd_flags.as_bitfield |= CORE_TX_BD_FLAGS_START_BD_MASK <<
 	    CORE_TX_BD_FLAGS_START_BD_SHIFT;
 	SET_FIELD(start_bd->bitfield0, CORE_TX_BD_NBDS, num_of_bds);
+	SET_FIELD(start_bd->bitfield0, CORE_TX_BD_ROCE_FLAV, type);
 	DMA_REGPAIR_LE(start_bd->addr, first_frag);
 	start_bd->nbytes = cpu_to_le16(first_frag_len);
 
-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
