From: Gabriel C <nix.or.die@gmail.com>
Subject: ath10k_htt_rx_amsdu_allowed() noise
Date: Mon, 17 Jul 2017 00:56:48 +0200
Message-ID: <edbe270b-ba70-b844-f814-53d04d07d253@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ath10k@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

each time I disconnect my card from AP my dmesg gets flooded like this :

...
ath10k_pci 0000:03:00.0: no channel configured; ignoring frame(s)!
<until ratelimit kicks in>
ath10k_warn: 155 callbacks suppressed
<and so on>

Can ath10k_warn() be ath10k_dbg() there ? Maybe this ?


 From d4138d936635ca7b69ed7f7b0cda4914f0f07917 Mon Sep 17 00:00:00 2001
From: Gabriel Craciunescu <nix.or.die@gmail.com>
Date: Mon, 17 Jul 2017 00:45:29 +0200
Subject: [PATCH] ath10k_htt_rx_amsdu_allowed(): change ath10k_warn() to th10k_dbg()

Signed-off-by: Gabriel Craciunescu <nix.or.die@gmail.com>
---
  drivers/net/wireless/ath/ath10k/htt_rx.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/htt_rx.c b/drivers/net/wireless/ath/ath10k/htt_rx.c
index 398dda978d6e..ad0306cd6ee1 100644
--- a/drivers/net/wireless/ath/ath10k/htt_rx.c
+++ b/drivers/net/wireless/ath/ath10k/htt_rx.c
@@ -1514,7 +1514,7 @@ static bool ath10k_htt_rx_amsdu_allowed(struct ath10k *ar,
          */

         if (!rx_status->freq) {
-               ath10k_warn(ar, "no channel configured; ignoriframe(s)!\n");
+               ath10k_dbg(ar, ATH10K_DBG_HTT, "no channel configured, ignoring frame(s)!\n");
                 return false;
         }

-- 
2.13.3
