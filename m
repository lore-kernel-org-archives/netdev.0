From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] net: rocker: Use ether_addr_equal
Date: Thu, 30 Apr 2015 15:21:29 +0900
Message-ID: <1430374889-7479-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34745 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbbD3GVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 02:21:41 -0400
Received: by pacyx8 with SMTP id yx8so50292514pac.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 23:21:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A small cleanup to make use of the ether_addr_equal helper.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
Compile tested only
---
 drivers/net/ethernet/rocker/rocker.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index a570a60533be..062ba168d893 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -2500,7 +2500,7 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	if (eth_dst_mask) {
 		entry->key.bridge.has_eth_dst_mask = 1;
 		ether_addr_copy(entry->key.bridge.eth_dst_mask, eth_dst_mask);
-		if (memcmp(eth_dst_mask, ff_mac, ETH_ALEN))
+		if (!ether_addr_equal(eth_dst_mask, ff_mac))
 			wild = true;
 	}
 
@@ -2573,7 +2573,7 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 
 	priority = ROCKER_PRIORITY_ACL_NORMAL;
 	if (eth_dst && eth_dst_mask) {
-		if (memcmp(eth_dst_mask, mcast_mac, ETH_ALEN) == 0)
+		if (ether_addr_equal(eth_dst_mask, mcast_mac))
 			priority = ROCKER_PRIORITY_ACL_DFLT;
 		else if (is_link_local_ether_addr(eth_dst))
 			priority = ROCKER_PRIORITY_ACL_CTRL;
-- 
2.1.4
