From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: bridge: accept bridge own MAC address as local
Date: Fri, 12 Aug 2011 13:30:24 +0200
Message-ID: <20110812113024.GA8900@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-30.dex002.intermedia.net ([64.78.21.74]:26278 "EHLO
	dhost002-30.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751786Ab1HLLgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 07:36:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: accept bridge own MAC address as local
if MAC address of bridge is manually set (BR_SET_MAC_ADDR). Otherwise
only MAC addresses of bridge members will work if manually set.

Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
---
 net/bridge/br_input.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f06ee39..3adabe3 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -93,7 +93,9 @@ int br_handle_frame_finish(struct sk_buff *skb)
 			skb2 = skb;
 
 		br->dev->stats.multicast++;
-	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
+	} else if ((br->flags & BR_SET_MAC_ADDR &&
+		    !compare_ether_addr(br->bridge_id.addr, dest)) ||
+		   ((dst = __br_fdb_get(br, dest)) && dst->is_local)) {
 		skb2 = skb;
 		/* Do not forward the packet since it's local. */
 		skb = NULL;
-- 
1.7.4.1

