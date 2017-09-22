From: Colin King <colin.king@canonical.com>
Subject: [PATCH] i40e: make const array patterns static, reduces object code size
Date: Fri, 22 Sep 2017 15:11:38 +0100
Message-ID: <20170922141138.13038-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Don't populate const array patterns on the stack, instead make it
static. Makes the object code smaller by over 60 bytes:

Before:
   text	   data	    bss	    dec	    hex	filename
   1953	    496	      0	   2449	    991	i40e_diag.o

After:
   text	   data	    bss	    dec	    hex	filename
   1798	    584	      0	   2382	    94e	i40e_diag.o

(gcc 6.3.0, x86-64)

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/intel/i40e/i40e_diag.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_diag.c b/drivers/net/ethernet/intel/i40e/i40e_diag.c
index f141e78d409e..76ed56641864 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_diag.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_diag.c
@@ -36,7 +36,9 @@
 static i40e_status i40e_diag_reg_pattern_test(struct i40e_hw *hw,
 							u32 reg, u32 mask)
 {
-	const u32 patterns[] = {0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
+	static const u32 patterns[] = {
+		0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF
+	};
 	u32 pat, val, orig_val;
 	int i;
 
-- 
2.14.1
