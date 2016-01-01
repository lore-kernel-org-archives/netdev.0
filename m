From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 5/6] mwifiex: use to_delayed_work
Date: Fri,  1 Jan 2016 23:48:56 +0800
Message-ID: <2ae1e4a43ac4e78a747ffd52320ca4c7c275a4a7.1451661580.git.geliangtang@163.com>
References: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
In-Reply-To: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
References: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use to_delayed_work() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
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
2.5.0
