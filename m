From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH] stmmac: Fix type of local variable in stmmac_xmit
Date: Fri, 04 Mar 2016 08:19:04 +0100
Message-ID: <1457075944-6959-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	linux-kernel@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Variable entry holds result of jumbo_frm callback. It can be negative,
so the variable should be signed. The patch changes also type of related
first_entry variable to make code compact and coherent.

The problem has been detected using patch
scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci.

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4c5ce98..cd31a3c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1955,7 +1955,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int nopaged_len = skb_headlen(skb);
 	int i, csum_insertion = 0, is_jumbo = 0;
 	int nfrags = skb_shinfo(skb)->nr_frags;
-	unsigned int entry, first_entry;
+	int entry, first_entry;
 	struct dma_desc *desc, *first;
 	unsigned int enh_desc;
 
-- 
1.9.1
