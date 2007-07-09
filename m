From: akpm@linux-foundation.org
Subject: [patch 5/7] use is_power_of_2() in cxgb3/cxgb3_main.c
Date: Mon, 09 Jul 2007 11:50:22 -0700
Message-ID: <200707091850.l69IoMun001688@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	vignesh.babu@wipro.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57862 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756175AbXGISu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 14:50:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: vignesh babu <vignesh.babu@wipro.com>

Replace (n & (n-1)) with is_power_of_2()

Signed-off-by: vignesh babu <vignesh.babu@wipro.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/cxgb3/cxgb3_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff -puN drivers/net/cxgb3/cxgb3_main.c~use-is_power_of_2-in-cxgb3-cxgb3_mainc drivers/net/cxgb3/cxgb3_main.c
--- a/drivers/net/cxgb3/cxgb3_main.c~use-is_power_of_2-in-cxgb3-cxgb3_mainc
+++ a/drivers/net/cxgb3/cxgb3_main.c
@@ -43,6 +43,7 @@
 #include <linux/proc_fs.h>
 #include <linux/rtnetlink.h>
 #include <linux/firmware.h>
+#include <linux/log2.h>
 #include <asm/uaccess.h>
 
 #include "common.h"
@@ -1818,8 +1819,8 @@ static int cxgb_extension_ioctl(struct n
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
_
