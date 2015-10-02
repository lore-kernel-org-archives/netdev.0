From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH 1/1] i40e: re-use %*ph specifier to hexdump a data
Date: Fri,  2 Oct 2015 12:18:16 +0300
Message-ID: <1443777496-43299-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57386 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbbJBJSu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2015 05:18:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a custom approach change the code to use %*ph format
specifier.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 22 ++++------------------
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 22 ++++------------------
 2 files changed, 8 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 114dc64..3bc772c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -329,25 +329,11 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 			len = buf_len;
 		/* write the full 16-byte chunks */
 		for (i = 0; i < (len - 16); i += 16)
-			i40e_debug(hw, mask,
-				   "\t0x%04X  %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X\n",
-				   i, buf[i], buf[i + 1], buf[i + 2],
-				   buf[i + 3], buf[i + 4], buf[i + 5],
-				   buf[i + 6], buf[i + 7], buf[i + 8],
-				   buf[i + 9], buf[i + 10], buf[i + 11],
-				   buf[i + 12], buf[i + 13], buf[i + 14],
-				   buf[i + 15]);
+			i40e_debug(hw, mask, "\t0x%04X  %16ph\n", i, buf + i);
 		/* write whatever's left over without overrunning the buffer */
-		if (i < len) {
-			char d_buf[80];
-			int j = 0;
-
-			memset(d_buf, 0, sizeof(d_buf));
-			j += sprintf(d_buf, "\t0x%04X ", i);
-			while (i < len)
-				j += sprintf(&d_buf[j], " %02X", buf[i++]);
-			i40e_debug(hw, mask, "%s\n", d_buf);
-		}
+		if (i < len)
+			i40e_debug(hw, mask, "\t0x%04X  %*ph\n",
+					     i, len - i, buf + i);
 	}
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index d45d0ae..200bbcb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -329,25 +329,11 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 			len = buf_len;
 		/* write the full 16-byte chunks */
 		for (i = 0; i < (len - 16); i += 16)
-			i40e_debug(hw, mask,
-				   "\t0x%04X  %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X\n",
-				   i, buf[i], buf[i + 1], buf[i + 2],
-				   buf[i + 3], buf[i + 4], buf[i + 5],
-				   buf[i + 6], buf[i + 7], buf[i + 8],
-				   buf[i + 9], buf[i + 10], buf[i + 11],
-				   buf[i + 12], buf[i + 13], buf[i + 14],
-				   buf[i + 15]);
+			i40e_debug(hw, mask, "\t0x%04X  %16ph\n", i, buf + i);
 		/* write whatever's left over without overrunning the buffer */
-		if (i < len) {
-			char d_buf[80];
-			int j = 0;
-
-			memset(d_buf, 0, sizeof(d_buf));
-			j += sprintf(d_buf, "\t0x%04X ", i);
-			while (i < len)
-				j += sprintf(&d_buf[j], " %02X", buf[i++]);
-			i40e_debug(hw, mask, "%s\n", d_buf);
-		}
+		if (i < len)
+			i40e_debug(hw, mask, "\t0x%04X  %*ph\n",
+					     i, len - i, buf + i);
 	}
 }
 
-- 
2.5.1
