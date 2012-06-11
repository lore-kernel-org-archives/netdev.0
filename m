From: Tony Cheneau <tony.cheneauh@amnesiak.org>
Subject: [PATCH net-next 1/4] 6lowpan: Fix in UDP uncompression function
 when a null pointer gets dereferenced
Date: Mon, 11 Jun 2012 00:38:52 -0400
Message-ID: <20120611003852.265750da@dualbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com
To: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:52959 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712Ab2FKEqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 00:46:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a UDP packet gets fragmented, a crash will occur during
reassembly.
skb->transport_header is not set during earlier period of fragment
reassembly. As a consequence, calll to udp_hdr() return NULL and uh
(which is NULL) gets dereferenced without much test.
I will post a patch later that will set skb->transport_header
 correctly in lowpan_process_data(), so that
lowpan_uncompress_udp_header() behave as intended.
---
 net/ieee802154/6lowpan.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 32eb417..a52e795 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -317,6 +317,9 @@ lowpan_uncompress_udp_header(struct sk_buff *skb)
 {
 	struct udphdr *uh = udp_hdr(skb);
 	u8 tmp;
+	
+	if (!uh)
+		goto err;
 
 	tmp = lowpan_fetch_skb_u8(skb);
 
-- 
1.7.3.4
