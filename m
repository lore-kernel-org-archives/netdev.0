From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mwifiex: make const array tos_to_ac static, reduces object code size
Date: Tue, 19 Sep 2017 22:05:00 +0100
Message-ID: <20170919210500.31330-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Amitkumar Karwar <amitkarwar@gmail.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Don't populate the read-only const array tos_to_ac on the stack,
instead make it static. Makes the object code smaller by 250 bytes:

Before:
   text	   data	    bss	    dec	    hex	filename
  26104	   2720	    128	  28952	   7118	wmm.o

After:
   text	   data	    bss	    dec	    hex	filename
  25758	   2816	    128	  28702	   701e	wmm.o

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/marvell/mwifiex/wmm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/wmm.c b/drivers/net/wireless/marvell/mwifiex/wmm.c
index 0edd26881321..936a0a841af8 100644
--- a/drivers/net/wireless/marvell/mwifiex/wmm.c
+++ b/drivers/net/wireless/marvell/mwifiex/wmm.c
@@ -359,7 +359,8 @@ static enum mwifiex_wmm_ac_e
 mwifiex_wmm_convert_tos_to_ac(struct mwifiex_adapter *adapter, u32 tos)
 {
 	/* Map of TOS UP values to WMM AC */
-	const enum mwifiex_wmm_ac_e tos_to_ac[] = { WMM_AC_BE,
+	static const enum mwifiex_wmm_ac_e tos_to_ac[] = {
+		WMM_AC_BE,
 		WMM_AC_BK,
 		WMM_AC_BK,
 		WMM_AC_BE,
-- 
2.14.1
