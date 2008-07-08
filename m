From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 06/25] ixgb: don't allow too small MTU
Date: Tue, 08 Jul 2008 15:51:32 -0700
Message-ID: <20080708225132.6925.29714.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11452 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753528AbYGHWvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:51:33 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 60cad65..0e72dad 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1566,9 +1566,9 @@ ixgb_change_mtu(struct net_device *netdev, int new_mtu)
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 	int old_max_frame = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 
-
-	if((max_frame < IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
-	   || (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
+	/* MTU < 68 is an error for IPv4 traffic, just don't allow it */
+	if ((new_mtu < 68) ||
+	    (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
 		DPRINTK(PROBE, ERR, "Invalid MTU setting %d\n", new_mtu);
 		return -EINVAL;
 	}

