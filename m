From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] ipv6: Keep index within tab_unreach[]
Date: Tue, 16 Jun 2009 20:40:21 +0200
Message-ID: <4A37E715.4060504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:45611 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843AbZFPQkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 12:40:16 -0400
Received: by bwz9 with SMTP id 9so4198615bwz.37
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 09:40:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure that index `code' remains within array tab_unreach[]

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 36dff88..8f850de 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -923,7 +923,7 @@ int icmpv6_err_convert(int type, int code, int *err)
 	switch (type) {
 	case ICMPV6_DEST_UNREACH:
 		fatal = 1;
-		if (code <= ICMPV6_PORT_UNREACH) {
+		if (code <= ICMPV6_PORT_UNREACH && code >= 0) {
 			*err  = tab_unreach[code].err;
 			fatal = tab_unreach[code].fatal;
 		}
