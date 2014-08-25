From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 3/3] net/bnx2x: Use is_kdump_kernel() to detect kdump kernel
Date: Mon, 25 Aug 2014 16:06:54 +0300
Message-ID: <1408972014-13319-4-git-send-email-amirv@mellanox.com>
References: <1408972014-13319-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Vivek Goyal <vgoyal@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michal Schmidt <mschmidt@redhat.com>
To: "David S. Miller" <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:36997 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932146AbaHYNHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 09:07:50 -0400
In-Reply-To: <1408972014-13319-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use is_kdump_kernel() to detect kdump kernel, instead of
reset_devices.

CC: Ariel Elior <ariel.elior@qlogic.com>
CC: Michal Schmidt <mschmidt@redhat.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 2388144..c99087f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -21,6 +21,7 @@
 #include <linux/if_vlan.h>
 #include <linux/interrupt.h>
 #include <linux/ip.h>
+#include <linux/crash_dump.h>
 #include <net/tcp.h>
 #include <net/ipv6.h>
 #include <net/ip6_checksum.h>
@@ -64,7 +65,7 @@ static int bnx2x_calc_num_queues(struct bnx2x *bp)
 	int nq = bnx2x_num_queues ? : netif_get_num_default_rss_queues();
 
 	/* Reduce memory usage in kdump environment by using only one queue */
-	if (reset_devices)
+	if (is_kdump_kernel())
 		nq = 1;
 
 	nq = clamp(nq, 1, BNX2X_MAX_QUEUES(bp));
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a008f48..0728c02 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -41,6 +41,7 @@
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/if_vlan.h>
+#include <linux/crash_dump.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
@@ -11956,7 +11957,7 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 	bp->disable_tpa = disable_tpa;
 	bp->disable_tpa |= IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp);
 	/* Reduce memory usage in kdump environment by disabling TPA */
-	bp->disable_tpa |= reset_devices;
+	bp->disable_tpa |= is_kdump_kernel();
 
 	/* Set TPA flags */
 	if (bp->disable_tpa) {
-- 
1.8.3.4
