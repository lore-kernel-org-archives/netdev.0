From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 1/2] flow_dissector: clean up IPIP case
Date: Mon, 29 Jul 2013 11:07:36 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1307291103330.21411@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:46627 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab3G2SiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 14:38:08 -0400
Received: by mail-vc0-f202.google.com with SMTP id gd11so295499vcb.3
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 11:38:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Explicitly set proto to ETH_P_IP and jump directly to ip processing.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/flow_dissector.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 00ee068..3259446 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -139,7 +139,8 @@ ipv6:
 		break;
 	}
 	case IPPROTO_IPIP:
-		goto again;
+		proto = htons(ETH_P_IP);
+		goto ip;
 	default:
 		break;
 	}
-- 
1.8.3
