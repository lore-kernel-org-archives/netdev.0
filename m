From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] mwifiex: Use to_delayed_work()
Date: Wed, 17 Feb 2016 18:03:37 +0530
Message-ID: <20160217123336.GA30230@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: akarwar@marvell.com, nishants@marvell.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce the use of to_delayed_work() helper function instead of open
coding it with container_of()

A simplified version of the Coccinelle semantic patch used to make
this change is:

//<smpl>
@@
expression a;
symbol work;
@@
- container_of(a, struct delayed_work, work)
+ to_delayed_work(a)
//</smpl>

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/net/wireless/marvell/mwifiex/11h.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/11h.c b/drivers/net/wireless/marvell/mwifiex/11h.c
index 71a1b58..81c60d0 100644
--- a/drivers/net/wireless/marvell/mwifiex/11h.c
+++ b/drivers/net/wireless/marvell/mwifiex/11h.c
@@ -123,8 +123,7 @@ void mwifiex_11h_process_join(struct mwifiex_private *priv, u8 **buffer,
 void mwifiex_dfs_cac_work_queue(struct work_struct *work)
 {
 	struct cfg80211_chan_def chandef;
-	struct delayed_work *delayed_work =
-			container_of(work, struct delayed_work, work);
+	struct delayed_work *delayed_work = to_delayed_work(work);
 	struct mwifiex_private *priv =
 			container_of(delayed_work, struct mwifiex_private,
 				     dfs_cac_work);
@@ -289,8 +288,7 @@ int mwifiex_11h_handle_radar_detected(struct mwifiex_private *priv,
 void mwifiex_dfs_chan_sw_work_queue(struct work_struct *work)
 {
 	struct mwifiex_uap_bss_param *bss_cfg;
-	struct delayed_work *delayed_work =
-			container_of(work, struct delayed_work, work);
+	struct delayed_work *delayed_work = to_delayed_work(work);
 	struct mwifiex_private *priv =
 			container_of(delayed_work, struct mwifiex_private,
 				     dfs_chan_sw_work);
-- 
1.9.1
