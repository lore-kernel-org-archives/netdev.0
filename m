From: Tom Herbert <therbert@google.com>
Subject: [PATCH] flow_diseector: Add support for IPPROTO_IPV6
Date: Mon, 29 Jul 2013 08:06:51 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1307290805030.13533@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f73.google.com ([209.85.212.73]:47115 "EHLO
	mail-vb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756147Ab3G2PMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 11:12:20 -0400
Received: by mail-vb0-f73.google.com with SMTP id e12so127203vbg.2
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 08:12:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for dissecting flows in IPv6/IPv4 packets.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/flow_dissector.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 00ee068..96901de 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -139,7 +139,11 @@ ipv6:
 		break;
 	}
 	case IPPROTO_IPIP:
-		goto again;
+		proto = __constant_htons(ETH_P_IP);
+		goto ip;
+	case IPPROTO_IPV6:
+		proto = __constant_htons(ETH_P_IPV6);
+		goto ipv6;
 	default:
 		break;
 	}
-- 
1.8.3
