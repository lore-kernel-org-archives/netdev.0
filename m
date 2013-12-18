From: Tom Herbert <therbert@google.com>
Subject: [PATCH 12/15] net: vxge calls skb_set_hash
Date: Tue, 17 Dec 2013 23:31:36 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172330060.24389@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:58613 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014Ab3LRHbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:31:38 -0500
Received: by mail-qa0-f73.google.com with SMTP id o15so13831qap.0
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:31:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 5d4ad58..11b1c70 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -507,7 +507,8 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 		 * if rss is disabled/enabled, so key off of that.
 		 */
 		if (ext_info.rth_value)
-			skb->rxhash = ext_info.rth_value;
+			skb_set_hash(skb, ext_info.rth_value,
+				     PKT_HASH_TYPE_L3);
 
 		vxge_rx_complete(ring, skb, ext_info.vlan,
 			pkt_length, &ext_info);
-- 
1.8.5.1
