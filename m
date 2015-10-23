From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/17] i40e: re-use %*ph specifier to hexdump a data
Date: Fri, 23 Oct 2015 06:17:51 -0700
Message-ID: <1445606279-19345-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61352 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879AbbJWNSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:18 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Instead of using a custom approach change the code to use %*ph format
specifier.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 22 ++++------------------
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 22 ++++------------------
 2 files changed, 8 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 5d533d1..2d74c6e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -331,25 +331,11 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
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
index a4c5a49..72b1942 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -331,25 +331,11 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
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
2.4.3
