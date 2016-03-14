From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 4/5] ath9k: fix misleading indentation
Date: Mon, 14 Mar 2016 15:18:37 +0100
Message-ID: <1457965120-3155420-5-git-send-email-arnd@arndb.de>
References: <1457965120-3155420-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457965120-3155420-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A cleanup patch in linux-3.18 moved around some code in the ath9k
driver and left some code to be indented in a misleading way,
made worse by the addition of some new code for p2p mode, as
discovered by a new gcc-6 warning:

drivers/net/wireless/ath/ath9k/init.c: In function 'ath9k_set_hw_capab':
drivers/net/wireless/ath/ath9k/init.c:851:4: warning: statement is indented as if it were guarded by... [-Wmisleading-indentation]
    hw->wiphy->iface_combinations = if_comb;
    ^~
drivers/net/wireless/ath/ath9k/init.c:847:3: note: ...this 'if' clause, but it is not
   if (ath9k_is_chanctx_enabled())
   ^~

The code is in fact correct, but the indentation is not, so I'm
reformatting it as it should have been after the original cleanup.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 499afaccf6f3 ("ath9k: Isolate ath9k_use_chanctx module parameter")
Fixes: eb61f9f623f7 ("ath9k: advertise p2p dev support when chanctx")
---
 drivers/net/wireless/ath/ath9k/init.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index d4e0ac946c3a..1c226d63bb03 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -848,8 +848,8 @@ static void ath9k_set_hw_capab(struct ath_softc *sc, struct ieee80211_hw *hw)
 			hw->wiphy->interface_modes |=
 					BIT(NL80211_IFTYPE_P2P_DEVICE);
 
-			hw->wiphy->iface_combinations = if_comb;
-			hw->wiphy->n_iface_combinations = ARRAY_SIZE(if_comb);
+		hw->wiphy->iface_combinations = if_comb;
+		hw->wiphy->n_iface_combinations = ARRAY_SIZE(if_comb);
 	}
 
 	hw->wiphy->flags &= ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
-- 
2.7.0
