From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] flow_dissector: support L2 GRE
Date: Mon, 11 Mar 2013 17:52:28 +0100
Message-ID: <1363020748.13690.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Michael Dalton <mwdalton@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:60514 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815Ab3CKQwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 12:52:34 -0400
Received: by mail-ea0-f173.google.com with SMTP id h14so1276049eak.18
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 09:52:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Dalton <mwdalton@google.com>

Add support for L2 GRE tunnels, so that RPS can be more effective.

Signed-off-by: Michael Dalton <mwdalton@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/flow_dissector.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 9d4c720..f8d9e03 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -119,6 +119,17 @@ ipv6:
 				nhoff += 4;
 			if (hdr->flags & GRE_SEQ)
 				nhoff += 4;
+			if (proto == htons(ETH_P_TEB)) {
+				const struct ethhdr *eth;
+				struct ethhdr _eth;
+
+				eth = skb_header_pointer(skb, nhoff,
+							 sizeof(_eth), &_eth);
+				if (!eth)
+					return false;
+				proto = eth->h_proto;
+				nhoff += sizeof(*eth);
+			}
 			goto again;
 		}
 		break;
