From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH v2] cfg80211: Remove deprecated create_singlethread_workqueue
Date: Wed, 31 Aug 2016 00:35:07 +0530
Message-ID: <20160830190507.GA11493@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33244 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751702AbcH3TFL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 15:05:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The workqueue "cfg80211_wq" is involved in cleanup, scan and event related
works. It queues multiple work items &rdev->event_work,
&rdev->dfs_update_channels_wk,
&wiphy_to_rdev(request->wiphy)->scan_done_wk,
&wiphy_to_rdev(wiphy)->sched_scan_results_wk, which require strict
execution ordering.
Hence, an ordered dedicated workqueue has been used.

Since it's a wireless driver, WQ_MEM_RECLAIM has been set to ensure
forward progress under memory pressure.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 net/wireless/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/wireless/core.c b/net/wireless/core.c
index d25c82b..2cd4563 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -1218,7 +1218,7 @@ static int __init cfg80211_init(void)
 	if (err)
 		goto out_fail_reg;

-	cfg80211_wq = create_singlethread_workqueue("cfg80211");
+	cfg80211_wq = alloc_ordered_workqueue("cfg80211", WQ_MEM_RECLAIM);
 	if (!cfg80211_wq) {
 		err = -ENOMEM;
 		goto out_fail_wq;
