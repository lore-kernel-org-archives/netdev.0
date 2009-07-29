From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] [IPV4]: Buffer overflow
Date: Wed, 29 Jul 2009 12:52:50 +0200
Message-ID: <4A702A02.30509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:49440 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbZG2Kt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 06:49:59 -0400
Received: by ewy26 with SMTP id 26so717244ewy.37
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 03:49:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If arp_format_neigh_entry() can be called with n->dev->addr_len == 0, then a
write to hbuffer[-1] occurs.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Found with Parfait, http://research.sun.com/projects/parfait/

It's not clear whether this can happen or not.

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c29d75d..252336f 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1304,7 +1304,8 @@ static void arp_format_neigh_entry(struct seq_file *seq,
 		hbuffer[k++] = hex_asc_lo(n->ha[j]);
 		hbuffer[k++] = ':';
 	}
-	hbuffer[--k] = 0;
+	if (k != 0)
+		hbuffer[--k] = 0;
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 	}
 #endif
