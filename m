From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Subject: [PATCH 1/2] pch_gbe: Fixed the issue on which PC was frozen when link was downed.
Date: Mon, 26 Sep 2011 16:27:42 +0900
Message-ID: <1317022063-12143-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, tomoya-linux@dsn.okisemi.com,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a link was downed during network use,
there is an issue on which PC freezes.

This patch fixed this issue.

Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 567ff10..5474189 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -2195,7 +2195,7 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 		/* If no Tx and not enough Rx work done,
 		 * exit the polling mode
 		 */
-		if ((work_done < budget) || !netif_running(netdev))
+		if (work_done < budget)
 			poll_end_flag = true;
 	}
 
-- 
1.7.4.4
