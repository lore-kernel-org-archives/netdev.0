From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6 4/4] net: e1000e: convert to use mc helpers
Date: Fri, 5 Feb 2010 13:52:39 +0100
Message-ID: <20100205125238.GB7968@psychotron.redhat.com>
References: <20100205124623.GD2650@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41270 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753573Ab0BEMwl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 07:52:41 -0500
Content-Disposition: inline
In-Reply-To: <20100205124623.GD2650@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/e1000e/netdev.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index ffa37c6..88d54d3 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2589,21 +2589,16 @@ static void e1000_set_multi(struct net_device *netdev)
 
 	ew32(RCTL, rctl);
 
-	if (netdev->mc_count) {
-		mta_list = kmalloc(netdev->mc_count * 6, GFP_ATOMIC);
+	if (!netdev_mc_empty(netdev)) {
+		mta_list = kmalloc(netdev_mc_count(netdev) * 6, GFP_ATOMIC);
 		if (!mta_list)
 			return;
 
 		/* prepare a packed array of only addresses. */
-		mc_ptr = netdev->mc_list;
-
-		for (i = 0; i < netdev->mc_count; i++) {
-			if (!mc_ptr)
-				break;
-			memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr,
-			       ETH_ALEN);
-			mc_ptr = mc_ptr->next;
-		}
+		i = 0;
+		netdev_for_each_mc_addr(mc_ptr, netdev)
+			memcpy(mta_list + (i++ * ETH_ALEN),
+			       mc_ptr->dmi_addr, ETH_ALEN);
 
 		e1000_update_mc_addr_list(hw, mta_list, i);
 		kfree(mta_list);
-- 
1.6.6

