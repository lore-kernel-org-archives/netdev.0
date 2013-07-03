From: Simon Horman <horms@verge.net.au>
Subject: [PATCH net-next] core: Copy inner_protocol in copy_skb_header()
Date: Wed,  3 Jul 2013 16:04:25 +0900
Message-ID: <1372835065-32087-1-git-send-email-horms@verge.net.au>
Cc: Joe Stringer <joe@wand.net.nz>, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:57033 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938Ab3GCHEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 03:04:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@wand.net.nz>

inner_protocol was added to struct sk_buff in
0d89d2035fe063461a5ddb609b2c12e7fb006e44 ("MPLS: Add limited GSO support"),
which is scheduled to be included in v3.11.

That patch did not update __copy_skb_header to copy the inner_protocol.

Signed-off-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/core/skbuff.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b1fcb87..ee08e63 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -693,6 +693,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->transport_header	= old->transport_header;
 	new->network_header	= old->network_header;
 	new->mac_header		= old->mac_header;
+	new->inner_protocol	= old->inner_protocol;
 	new->inner_transport_header = old->inner_transport_header;
 	new->inner_network_header = old->inner_network_header;
 	new->inner_mac_header = old->inner_mac_header;
-- 
1.8.2.1
