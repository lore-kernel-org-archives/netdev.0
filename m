From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 20/38] net: brcm80211: fix range check
Date: Mon, 21 Sep 2015 15:33:52 +0200
Message-ID: <1442842450-29769-21-git-send-email-a.hajda@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unsigned minus constant is still unsigned so checking its sign makes no
sense.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2038576

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/net/wireless/brcm80211/brcmsmac/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index 9728be0..218cbc8 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -4585,7 +4585,7 @@ static int brcms_b_attach(struct brcms_c_info *wlc, struct bcma_device *core,
 		wlc_hw->machwcap_backup = wlc_hw->machwcap;
 
 		/* init tx fifo size */
-		WARN_ON((wlc_hw->corerev - XMTFIFOTBL_STARTREV) < 0 ||
+		WARN_ON(wlc_hw->corerev < XMTFIFOTBL_STARTREV ||
 			(wlc_hw->corerev - XMTFIFOTBL_STARTREV) >
 				ARRAY_SIZE(xmtfifo_sz));
 		wlc_hw->xmtfifo_sz =
-- 
1.9.1
