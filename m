From: vignesh babu <vignesh.babu@wipro.com>
Subject: [PATCH]is_power_of_2-cxgb3/cxgb3_main.c
Date: Tue, 12 Jun 2007 10:30:57 +0530
Message-ID: <1181624457.3109.21.camel@merlin.linuxcoe.com>
Reply-To: vignesh.babu@wipro.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel Janitors List <kernel-janitors@lists.osdl.org>
To: akpm <akpm@linux-foundation.org>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:38892 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbXFLFCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 01:02:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Replacing (n & (n-1)) in the context of power of 2 checks
with is_power_of_2

Signed-off-by: vignesh babu <vignesh.babu@wipro.com>
--- 
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 1b20f40..a124b33 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -43,6 +43,7 @@
 #include <linux/proc_fs.h>
 #include <linux/rtnetlink.h>
 #include <linux/firmware.h>
+#include <linux/log2.h>
 #include <asm/uaccess.h>
 
 #include "common.h"
@@ -1818,8 +1819,8 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 			return -EBUSY;
 		if (copy_from_user(&m, useraddr, sizeof(m)))
 			return -EFAULT;
-		if (!m.rx_pg_sz || (m.rx_pg_sz & (m.rx_pg_sz - 1)) ||
-			!m.tx_pg_sz || (m.tx_pg_sz & (m.tx_pg_sz - 1)))
+		if (!is_power_of_2(m.rx_pg_sz) ||
+			!is_power_of_2(m.tx_pg_sz))
 			return -EINVAL;	/* not power of 2 */
 		if (!(m.rx_pg_sz & 0x14000))
 			return -EINVAL;	/* not 16KB or 64KB */

-- 
Vignesh Babu BM 
_____________________________________________________________ 
"Why is it that every time I'm with you, makes me believe in magic?"

