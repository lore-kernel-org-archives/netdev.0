From: Colin King <colin.king@canonical.com>
Subject: [PATCH] wireless: iwlegacy:  make const array static to shink object code size Content-Type: text/plain; charset="utf-8" Content-Transfer-Encoding: 8bit
Date: Thu, 21 Sep 2017 23:56:30 +0100
Message-ID: <20170921225630.21916-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Don't populate const array ac_to_fifo on the stack in an inlined
function, instead make it static.  Makes the object code smaller
by over 800 bytes:

   text	   data	    bss	    dec	    hex	filename
 159029	  33154	   1216	 193399	  2f377	4965-mac.o

   text	   data	    bss	    dec	    hex	filename
 158122	  33250	   1216	 192588	  2f04c	4965-mac.o

(gcc version 7.2.0 x86_64)

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/intel/iwlegacy/4965-mac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlegacy/4965-mac.c b/drivers/net/wireless/intel/iwlegacy/4965-mac.c
index de9b6522c43f..65eba2c24292 100644
--- a/drivers/net/wireless/intel/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/intel/iwlegacy/4965-mac.c
@@ -1480,7 +1480,7 @@ il4965_get_ac_from_tid(u16 tid)
 static inline int
 il4965_get_fifo_from_tid(u16 tid)
 {
-	const u8 ac_to_fifo[] = {
+	static const u8 ac_to_fifo[] = {
 		IL_TX_FIFO_VO,
 		IL_TX_FIFO_VI,
 		IL_TX_FIFO_BE,
-- 
2.14.1
