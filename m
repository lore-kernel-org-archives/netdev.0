From: Tom Herbert <therbert@google.com>
Subject: [PATCH 14/17] net: vxge calls skb_get_rxhash
Date: Mon, 25 Nov 2013 21:57:13 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252156060.22983@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f74.google.com ([209.85.128.74]:61139 "EHLO
	mail-qe0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007Ab3KZF5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:57:14 -0500
Received: by mail-qe0-f74.google.com with SMTP id b10so264434qen.3
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:57:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_get_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 8614eeb..17749a2 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -507,7 +507,8 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 		 * if rss is disabled/enabled, so key off of that.
 		 */
 		if (ext_info.rth_value)
-			skb->rxhash = ext_info.rth_value;
+			skb_set_rxhash(skb, ext_info.rth_value,
+				       RXHASH_TYPE_L3);
 
 		vxge_rx_complete(ring, skb, ext_info.vlan,
 			pkt_length, &ext_info);
-- 
1.8.4.1
