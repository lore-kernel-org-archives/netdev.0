From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH] nets: fix a buffer overrun
Date: Sat, 8 Nov 2008 10:35:58 +0800
Message-ID: <20081108023558.GB6384@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-Kernel-Mailing-List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:60823 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780AbYKHCfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 21:35:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net/mac80211/debugfs_sta.c
The trailing zero was written to state[4], it's out of bounds.

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/mac80211/debugfs_sta.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/debugfs_sta.c b/net/mac80211/debugfs_sta.c
index 189d0ba..b85c4f2 100644
--- a/net/mac80211/debugfs_sta.c
+++ b/net/mac80211/debugfs_sta.c
@@ -199,7 +199,7 @@ static ssize_t sta_agg_status_write(struct file *file,
 		/* toggle Rx aggregation command */
 		tid_num = tid_num - 100;
 		if (tid_static_rx[tid_num] == 1) {
-			strcpy(state, "off ");
+			strcpy(state, "off");
 			ieee80211_sta_stop_rx_ba_session(sta->sdata, da, tid_num, 0,
 					WLAN_REASON_QSTA_REQUIRE_SETUP);
 			sta->ampdu_mlme.tid_state_rx[tid_num] |=
-- 
1.5.6.3
