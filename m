From: Colin King <colin.king@canonical.com>
Subject: [PATCH] ath9k: make const array reg_hole_list static, reduces object code size
Date: Tue, 19 Sep 2017 21:40:19 +0100
Message-ID: <20170919204019.30804-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Don't populate the read-only array reg_hole_list on the stack, instead make
it static.  Makes the object code smaller by over 200 bytes:

Before:
   text	   data	    bss	    dec	    hex	filename
  57518	  15248	      0	  72766	  11c3e	debug.o

After:
   text	   data	    bss	    dec	    hex	filename
  57218	  15344	      0	  72562	  11b72	debug.o

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/ath/ath9k/debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index 01fa30117288..5a0a05abd51a 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -916,7 +916,7 @@ static int open_file_regdump(struct inode *inode, struct file *file)
 	u8 *buf;
 	int i, j = 0;
 	unsigned long num_regs, regdump_len, max_reg_offset;
-	const struct reg_hole {
+	static const struct reg_hole {
 		u32 start;
 		u32 end;
 	} reg_hole_list[] = {
-- 
2.14.1
