From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net] net: Reset secmark when scrubbing packet
Date: Tue, 23 Dec 2014 01:13:18 +0100
Message-ID: <efb09aca5173a9a18f15066c33a4998ed70bd34a.1419293504.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41390 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbaLWANX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 19:13:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_scrub_packet() is called when a packet switches between a context
such as between underlay and overlay, between namespaces, or between
L3 subnets.

While we already scrub the packet mark, connection tracking entry,
and cached destination, the security mark/context is left intact.

It seems wrong to inherit the security context of a packet when going
from overlay to underlay or across forwarding paths.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/core/skbuff.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ae13ef6..395c15b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4148,6 +4148,7 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet)
 	skb->ignore_df = 0;
 	skb_dst_drop(skb);
 	skb->mark = 0;
+	skb_init_secmark(skb);
 	secpath_reset(skb);
 	nf_reset(skb);
 	nf_reset_trace(skb);
-- 
1.9.3
