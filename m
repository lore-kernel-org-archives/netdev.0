From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] wlcore: consolidate kmalloc + memset 0 into kzalloc
Date: Mon, 21 Dec 2015 17:47:44 +0100
Message-ID: <1450716464-20759-1-git-send-email-hofrat@osadl.org>
Cc: Eliad Peller <eliad@wizery.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Arik Nemtsov <arik@wizery.com>,
	Tony Lindgren <tony@atomide.com>,
	Luciano Coelho <luca@coelho.fi>,
	Eyal Reizer <eyalreizer@gmail.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an API consolidation only. The use of kmalloc + memset to 0
is equivalent to kzalloc.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Found by coccinelle script (relaxed version of
scripts/coccinelle/api/alloc/kzalloc-simple.cocci)

Patch was compile tested with: x86_64_defconfig +
CONFIG_WL12XX=m (implies CONFIG_WLCORE=m)

Patch is against linux-next (localversion-next is -next-20151221)

 drivers/net/wireless/ti/wlcore/main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index ec7f6af..dfc49bf 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -838,7 +838,7 @@ static void wl12xx_read_fwlog_panic(struct wl1271 *wl)
 
 	wl1271_info("Reading FW panic log");
 
-	block = kmalloc(wl->fw_mem_block_size, GFP_KERNEL);
+	block = kzalloc(wl->fw_mem_block_size, GFP_KERNEL);
 	if (!block)
 		return;
 
@@ -885,7 +885,6 @@ static void wl12xx_read_fwlog_panic(struct wl1271 *wl)
 			goto out;
 		}
 
-		memset(block, 0, wl->fw_mem_block_size);
 		ret = wlcore_read_hwaddr(wl, addr, block,
 					wl->fw_mem_block_size, false);
 
-- 
2.1.4
