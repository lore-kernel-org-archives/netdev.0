From: Colin King <colin.king@canonical.com>
Subject: [PATCH] rtl8xxxu: fix uninitialized return value in ret
Date: Tue, 29 Mar 2016 17:44:36 +0100
Message-ID: <1459269876-15559-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Jes Sorensen <Jes.Sorensen@redhat.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

several functions are not initializing a return status in ret
resulting in garbage to be returned instead of 0 for success.
Currently, the calls to these functions are not checking the
return, however, it seems prudent to return the correct status
in case they are to be checked at a later date.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c
index abdff45..9262aad 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c
@@ -5231,7 +5231,7 @@ static void rtl8xxxu_set_ampdu_min_space(struct rtl8xxxu_priv *priv, u8 density)
 static int rtl8xxxu_active_to_emu(struct rtl8xxxu_priv *priv)
 {
 	u8 val8;
-	int count, ret;
+	int count, ret = 0;
 
 	/* Start of rtl8723AU_card_enable_flow */
 	/* Act to Cardemu sequence*/
@@ -5281,7 +5281,7 @@ static int rtl8723bu_active_to_emu(struct rtl8xxxu_priv *priv)
 	u8 val8;
 	u16 val16;
 	u32 val32;
-	int count, ret;
+	int count, ret = 0;
 
 	/* Turn off RF */
 	rtl8xxxu_write8(priv, REG_RF_CTRL, 0);
@@ -5338,7 +5338,7 @@ static int rtl8xxxu_active_to_lps(struct rtl8xxxu_priv *priv)
 {
 	u8 val8;
 	u8 val32;
-	int count, ret;
+	int count, ret = 0;
 
 	rtl8xxxu_write8(priv, REG_TXPAUSE, 0xff);
 
-- 
2.7.4
