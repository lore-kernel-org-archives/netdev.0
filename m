From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] octeon: convert to use netdev_for_each_mc_addr
Date: Tue, 23 Feb 2010 20:54:58 +0100
Message-ID: <20100223195457.GF2673@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40935 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252Ab0BWTzC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2010 14:55:02 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm so actually my original patch including this bit was correct,
"list = list->next;" confused me :) - will send patch correcting that in a few.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/octeon/octeon_mgmt.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 3a0f910..be368e5 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -467,7 +467,6 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
 	int port = p->port;
-	int i;
 	union cvmx_agl_gmx_rxx_adr_ctl adr_ctl;
 	union cvmx_agl_gmx_prtx_cfg agl_gmx_prtx;
 	unsigned long flags;
@@ -511,12 +510,8 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 		}
 	}
 	if (multicast_mode == 0) {
-		i = netdev_mc_count(netdev);
-		list = netdev->mc_list;
-		while (i--) {
+		netdev_for_each_mc_addr(list, netdev)
 			octeon_mgmt_cam_state_add(&cam_state, list->da_addr);
-			list = list->next;
-		}
 	}
 
 
-- 
1.6.6

