From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] i40e: make const array patterns static, reduces object code size
Date: Fri, 13 Oct 2017 14:52:47 -0700
Message-ID: <20171013215249.61286-8-jeffrey.t.kirsher@intel.com>
References: <20171013215249.61286-1-jeffrey.t.kirsher@intel.com>
Cc: Colin Ian King <colin.king@canonical.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:59784 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753080AbdJMVxW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 17:53:22 -0400
In-Reply-To: <20171013215249.61286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
2.14.2
