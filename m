From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Subject: [PATCH] ps3_gelic: use kmemdup
Date: Thu, 19 May 2016 19:24:41 +0530
Message-ID: <1463666090-16540-1-git-send-email-falakreyaz@gmail.com>
Cc: Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	"David S. Miller" <davem@davemloft.net>,
	Christophe Jaillet <christophe.jaillet@wanadoo.fr>,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use kmemdup when some other buffer is immediately copied into allocated
region. It replaces call to allocation followed by memcpy, by a single
call to kmemdup.

Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
---
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index 743b182..446ea58 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -1616,13 +1616,13 @@ static void gelic_wl_scan_complete_event(struct gelic_wl_info *wl)
 		target->valid = 1;
 		target->eurus_index = i;
 		kfree(target->hwinfo);
-		target->hwinfo = kzalloc(be16_to_cpu(scan_info->size),
+		target->hwinfo = kmemdup(scan_info,
+					 be16_to_cpu(scan_info->size),
 					 GFP_KERNEL);
 		if (!target->hwinfo)
 			continue;
 
 		/* copy hw scan info */
-		memcpy(target->hwinfo, scan_info, be16_to_cpu(scan_info->size));
 		target->essid_len = strnlen(scan_info->essid,
 					    sizeof(scan_info->essid));
 		target->rate_len = 0;
-- 
1.9.1
