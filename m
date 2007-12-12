From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter : xt_hashlimit should use time_after_eq()
Date: Wed, 12 Dec 2007 19:39:34 +0100
Message-ID: <47602AE6.6060908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010508000307000309010003"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp25.orange.fr ([193.252.22.22]:44669 "EHLO smtp25.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758456AbXLLSjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 13:39:44 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2516.orange.fr (SMTP Server) with ESMTP id 3150D1C000B2
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 19:39:42 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010508000307000309010003
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David & Patrick

I believe this patch is needed for linux-2.6.24

Thank you

[PATCH] netfilter : xt_hashlimit should use time_after_eq()

In order to avoid jiffies wraparound and its effect, special care must 
be taken
when doing comparisons ...

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------010508000307000309010003
Content-Type: text/plain;
 name="xt_hashlimit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="xt_hashlimit.patch"

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 1910367..2ef44d8 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -240,7 +240,7 @@ static bool select_all(const struct xt_hashlimit_htable *ht,
 static bool select_gc(const struct xt_hashlimit_htable *ht,
 		      const struct dsthash_ent *he)
 {
-	return jiffies >= he->expires;
+	return time_after_eq(jiffies, he->expires);
 }
 
 static void htable_selective_cleanup(struct xt_hashlimit_htable *ht,

--------------010508000307000309010003--


