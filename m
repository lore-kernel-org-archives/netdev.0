From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 15/15] {xfrm,pktgen} Fix compiling error when CONFIG_XFRM is not set
Date: Tue, 14 Jan 2014 07:49:19 +0100
Message-ID: <1389682159-3260-16-git-send-email-steffen.klassert@secunet.com>
References: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60099 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750777AbaANGto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:49:44 -0500
In-Reply-To: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

0-DAY kernel build testing backend reported below error:
All error/warnings:

   net/core/pktgen.c: In function 'pktgen_if_write':
>> >> net/core/pktgen.c:1487:10: error: 'struct pktgen_dev' has no member named 'spi'
>> >> net/core/pktgen.c:1488:43: error: 'struct pktgen_dev' has no member named 'spi'

Fix this by encapuslating the code with CONFIG_XFRM.

Cc: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/core/pktgen.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index a37ec53..fa3e128 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1482,7 +1482,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		sprintf(pg_result, "OK: flows=%u", pkt_dev->cflows);
 		return count;
 	}
-
+#ifdef CONFIG_XFRM
 	if (!strcmp(name, "spi")) {
 		len = num_arg(&user_buffer[i], 10, &value);
 		if (len < 0)
@@ -1493,7 +1493,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		sprintf(pg_result, "OK: spi=%u", pkt_dev->spi);
 		return count;
 	}
-
+#endif
 	if (!strcmp(name, "flowlen")) {
 		len = num_arg(&user_buffer[i], 10, &value);
 		if (len < 0)
-- 
1.7.9.5
