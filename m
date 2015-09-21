From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 21/38] mwifiex: fix comparison expression
Date: Mon, 21 Sep 2015 15:33:53 +0200
Message-ID: <1442842450-29769-22-git-send-email-a.hajda@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To avoid underflows signed variables should be used in expression.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2038576

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/net/wireless/mwifiex/11n_rxreorder.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/11n_rxreorder.c b/drivers/net/wireless/mwifiex/11n_rxreorder.c
index 2906cd5..b3970a8 100644
--- a/drivers/net/wireless/mwifiex/11n_rxreorder.c
+++ b/drivers/net/wireless/mwifiex/11n_rxreorder.c
@@ -615,10 +615,10 @@ int mwifiex_11n_rx_reorder_pkt(struct mwifiex_private *priv,
 	    ((end_win > start_win) && ((seq_num > end_win) ||
 				       (seq_num < start_win)))) {
 		end_win = seq_num;
-		if (((seq_num - win_size) + 1) >= 0)
+		if (((end_win - win_size) + 1) >= 0)
 			start_win = (end_win - win_size) + 1;
 		else
-			start_win = (MAX_TID_VALUE - (win_size - seq_num)) + 1;
+			start_win = (MAX_TID_VALUE - (win_size - end_win)) + 1;
 		mwifiex_11n_dispatch_pkt_until_start_win(priv, tbl, start_win);
 	}
 
-- 
1.9.1
