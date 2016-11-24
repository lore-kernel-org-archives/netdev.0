From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH 1/5] ath10k: Remove unused 'buf_len' variable
Date: Thu, 24 Nov 2016 00:01:23 -0800
Message-ID: <196e46eee00fd3ebb56da1373c36f3dff66f2ae1.1479974100.git.kirtika@chromium.org>
References: <cover.1479974100.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, Raja Mani <rmani@qti.qualcomm.com>,
        Michal Kazior <michal.kazior@tieto.com>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35482 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755734AbcKXIDj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 03:03:39 -0500
Content-Disposition: inline
In-Reply-To: <cover.1479974100.git.kirtika@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 32653cf19554 removed the call to 'skb_trim(skb, buf_len)'
in ath10k_wmi_event_mgmt_rx(), leaving the buf_len variable set but
unused. Compiling with W=1 gives the following warning, fix it.
drivers/net/wireless/ath/ath10k/wmi.c: In function ‘ath10k_wmi_event_mgmt_rx’:
drivers/net/wireless/ath/ath10k/wmi.c:2280:6: warning: variable ‘buf_len’ set but not used [-Wunused-but-set-variable]

This is a harmless warning, and is only being fixed to reduce the
noise with W=1 in the kernel.

Fixes: 32653cf19554 ("ath10k: implement intermediate event args")
Cc: Michal Kazior <michal.kazior@tieto.com>
Cc: Kalle Valo <kvalo@qca.qualcomm.com>
Signed-off-by: Kirtika Ruchandani <kirtika@chromium.org>
---
 drivers/net/wireless/ath/ath10k/wmi.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/wmi.c b/drivers/net/wireless/ath/ath10k/wmi.c
index 387c4ee..1f28187 100644
--- a/drivers/net/wireless/ath/ath10k/wmi.c
+++ b/drivers/net/wireless/ath/ath10k/wmi.c
@@ -2277,7 +2277,6 @@ int ath10k_wmi_event_mgmt_rx(struct ath10k *ar, struct sk_buff *skb)
	u32 phy_mode;
	u32 snr;
	u32 rate;
-	u32 buf_len;
	u16 fc;
	int ret;

@@ -2289,7 +2288,6 @@ int ath10k_wmi_event_mgmt_rx(struct ath10k *ar, struct sk_buff *skb)
	}

	channel = __le32_to_cpu(arg.channel);
-	buf_len = __le32_to_cpu(arg.buf_len);
	rx_status = __le32_to_cpu(arg.status);
	snr = __le32_to_cpu(arg.snr);
	phy_mode = __le32_to_cpu(arg.phy_mode);
