From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 3/4] 6lowpan: set 6lowpan network and transport header
Date: Wed, 30 Oct 2013 09:18:23 +0100
Message-ID: <1383121104-2515-4-git-send-email-alex.aring@gmail.com>
References: <1383121104-2515-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:63444 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab3J3ISj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 04:18:39 -0400
Received: by mail-ee0-f53.google.com with SMTP id e51so442372eek.12
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 01:18:38 -0700 (PDT)
In-Reply-To: <1383121104-2515-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is necessary to access network header with the skb_network_header
function instead of calculate the position with mac_len, etc.
Do the same for the transport header, when we replace the IPv6 header
with the 6LoWPAN header.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Acked-by: Werner Almesberger <werner@almesberger.net>
---
 net/ieee802154/6lowpan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index e6db1f5..58c07fd 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -654,7 +654,9 @@ static int lowpan_header_create(struct sk_buff *skb,
 	head[1] = iphc1;
 
 	skb_pull(skb, sizeof(struct ipv6hdr));
+	skb_reset_transport_header(skb);
 	memcpy(skb_push(skb, hc06_ptr - head), head, hc06_ptr - head);
+	skb_reset_network_header(skb);
 
 	lowpan_raw_dump_table(__func__, "raw skb data dump", skb->data,
 				skb->len);
-- 
1.8.4.2
