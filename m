From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 2/3] bnx2x: Reuse bnx2x_null_format_ver()
Date: Thu, 27 Apr 2017 16:37:00 +0300
Message-ID: <20170427133701.72701-2-andriy.shevchenko@linux.intel.com>
References: <20170427133701.72701-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        everest-linux-l2@cavium.com,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7256 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751194AbdD0Nhk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 09:37:40 -0400
In-Reply-To: <20170427133701.72701-1-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andy.shevchenko@gmail.com>

Reuse bnx2x_null_format_ver() in functions where it's appropriated
instead of open coded variant.

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 2acc4f081818..6d11a958200f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -6161,14 +6161,20 @@ static void bnx2x_link_int_ack(struct link_params *params,
 	}
 }
 
+static int bnx2x_null_format_ver(u32 spirom_ver, u8 *str, u16 *len)
+{
+	str[0] = '\0';
+	(*len)--;
+	return 0;
+}
+
 static int bnx2x_format_ver(u32 num, u8 *str, u16 *len)
 {
 	u16 ret;
 
 	if (*len < 10) {
 		/* Need more than 10chars for this format */
-		*str = '\0';
-		(*len)--;
+		bnx2x_null_format_ver(num, str, len);
 		return -EINVAL;
 	}
 
@@ -6183,8 +6189,7 @@ static int bnx2x_3_seq_format_ver(u32 num, u8 *str, u16 *len)
 
 	if (*len < 10) {
 		/* Need more than 10chars for this format */
-		*str = '\0';
-		(*len)--;
+		bnx2x_null_format_ver(num, str, len);
 		return -EINVAL;
 	}
 
@@ -6193,13 +6198,6 @@ static int bnx2x_3_seq_format_ver(u32 num, u8 *str, u16 *len)
 	return 0;
 }
 
-static int bnx2x_null_format_ver(u32 spirom_ver, u8 *str, u16 *len)
-{
-	str[0] = '\0';
-	(*len)--;
-	return 0;
-}
-
 int bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 *version,
 				 u16 len)
 {
-- 
2.11.0
