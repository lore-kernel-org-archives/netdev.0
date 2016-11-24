From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH 4/5] ath10k: Removed unused 'dev' in ath10k_ahb_clock_enable()
Date: Thu, 24 Nov 2016 00:02:13 -0800
Message-ID: <bef0ae334d0e58b26e826d295ad1a8d6c8fda639.1479974100.git.kirtika@chromium.org>
References: <cover.1479974100.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, Raja Mani <rmani@qti.qualcomm.com>,
        Michal Kazior <michal.kazior@tieto.com>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33894 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933514AbcKXIQM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 03:16:12 -0500
Content-Disposition: inline
In-Reply-To: <cover.1479974100.git.kirtika@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8beff219c528 introduced ath10k_ahb_clock_enable() which
defines and sets 'struct device* dev' but does not use it.
Compiling with W=1 gives the following warning, fix it.
drivers/net/wireless/ath/ath10k/ahb.c: In function ‘ath10k_ahb_clock_enable’:
drivers/net/wireless/ath/ath10k/ahb.c:133:17: warning: variable ‘dev’ set but not used [-Wunused-but-set-variable]

This is a harmless warning, and is only being fixed to reduce the
noise with W=1 in the kernel.

Fixes: 8beff219c528("ath10k: add clock ctrl related functions in ahb")
Cc: Raja Mani <rmani@qti.qualcomm.com>
Cc: Kalle Valo <kvalo@qca.qualcomm.com>
Signed-off-by: Kirtika Ruchandani <kirtika@chromium.org>
---
 drivers/net/wireless/ath/ath10k/ahb.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/ahb.c b/drivers/net/wireless/ath/ath10k/ahb.c
index 766c63b..8078d64 100644
--- a/drivers/net/wireless/ath/ath10k/ahb.c
+++ b/drivers/net/wireless/ath/ath10k/ahb.c
@@ -130,11 +130,8 @@ static void ath10k_ahb_clock_deinit(struct ath10k *ar)
 static int ath10k_ahb_clock_enable(struct ath10k *ar)
 {
	struct ath10k_ahb *ar_ahb = ath10k_ahb_priv(ar);
-	struct device *dev;
	int ret;

-	dev = &ar_ahb->pdev->dev;
-
	if (IS_ERR_OR_NULL(ar_ahb->cmd_clk) ||
	    IS_ERR_OR_NULL(ar_ahb->ref_clk) ||
	    IS_ERR_OR_NULL(ar_ahb->rtc_clk)) {
