From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: [PATCH net-next v3 1/3] 6lowpan: Fix null pointer dereference in UDP uncompression function
Date: Wed, 11 Jul 2012 12:51:14 -0400
Message-ID: <1342025476-20949-2-git-send-email-tony.cheneau@amnesiak.org>
References: <1342025476-20949-1-git-send-email-tony.cheneau@amnesiak.org>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:43741 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932081Ab2GKQwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 12:52:55 -0400
In-Reply-To: <1342025476-20949-1-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a UDP packet gets fragmented, a crash will occur at reassembly time.
This is because skb->transport_header is not set during earlier period of fragment reassembly.
As a consequence, call to udp_hdr() return NULL and uh (which is NULL) gets
dereferenced without much test.

Signed-off-by: Tony Cheneau <tony.cheneau@amnesiak.org>
---
 net/ieee802154/6lowpan.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index f4070e5..0c9f6d1 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -315,6 +315,9 @@ lowpan_uncompress_udp_header(struct sk_buff *skb)
 	struct udphdr *uh = udp_hdr(skb);
 	u8 tmp;
 
+	if (!uh)
+		goto err;
+
 	if (lowpan_fetch_skb_u8(skb, &tmp))
 		goto err;
 
-- 
1.7.3.4
