From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 4/5] igb: clean up a stray fake netdev code left in rx path
Date: Tue, 26 Aug 2008 04:25:11 -0700
Message-ID: <20080826112510.15627.75540.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112503.15627.3855.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37230 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844AbYHZLZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:25:11 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099147rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:25:11 -0700 (PDT)
In-Reply-To: <20080826112503.15627.3855.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Remove code that was in place to support fake netdev

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 8d47882..2728730 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3563,10 +3563,6 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 	struct net_device *netdev = adapter->netdev;
 	int work_done = 0;
 
-	/* Keep link state information with original netdev */
-	if (!netif_carrier_ok(netdev))
-		goto quit_polling;
-
 #ifdef CONFIG_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(rx_ring);
@@ -3576,7 +3572,6 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 
 	/* If not enough Rx work done, exit the polling mode */
 	if ((work_done == 0) || !netif_running(netdev)) {
-quit_polling:
 		netif_rx_complete(netdev, napi);
 
 		if (adapter->itr_setting & 3) {

