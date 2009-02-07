From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] ixgbe: Fix a set_num_queues() bug that can result in
	num_(r|t)x_queues = 0
Date: Sat, 07 Feb 2009 00:33:02 -0800
Message-ID: <20090207083257.15354.43853.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:36996 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbZBGIdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 03:33:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Now that our set_num_queues() routines for each feature are re-entrant, and
can be called at any point, they shouldn't zero out the feature's indices
or mask bits.  Subsequent calls into those routines for those features can
result in zero Rx and Tx queues being assigned, causing a panic later in
driver reinitialization.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 8e270b6..a3572d1 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2350,8 +2350,6 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 		                      adapter->ring_feature[RING_F_DCB].indices;
 		ret = true;
 	} else {
-		adapter->ring_feature[RING_F_DCB].mask = 0;
-		adapter->ring_feature[RING_F_DCB].indices = 0;
 		ret = false;
 	}
 
@@ -2371,8 +2369,6 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 		                      adapter->ring_feature[RING_F_RSS].indices;
 		ret = true;
 	} else {
-		adapter->ring_feature[RING_F_RSS].mask = 0;
-		adapter->ring_feature[RING_F_RSS].indices = 0;
 		ret = false;
 	}
 

