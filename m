From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 09/15] {pktgen, xfrm} Using "pgset spi xxx" to spedifiy SA for a given flow
Date: Tue, 14 Jan 2014 07:49:13 +0100
Message-ID: <1389682159-3260-10-git-send-email-steffen.klassert@secunet.com>
References: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60094 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752333AbaANGtj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:49:39 -0500
In-Reply-To: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

User could set specific SPI value to arm pktgen flow with IPsec
transformation, instead of looking up SA by sadr/daddr. The reaseon
to do so is because current state lookup scheme is both slow and, most
important of all, in fact pktgen doesn't need to match any SA state
addresses information, all it needs is the SA transfromation shell to
do the encapuslation.

And this option also provide user an alternative to using pktgen
test existing SA without creating new ones.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/core/pktgen.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 156d57b..8bc4ddd 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -389,6 +389,7 @@ struct pktgen_dev {
 #ifdef CONFIG_XFRM
 	__u8	ipsmode;		/* IPSEC mode (config) */
 	__u8	ipsproto;		/* IPSEC type (config) */
+	__u32	spi;
 #endif
 	char result[512];
 };
@@ -1477,6 +1478,17 @@ static ssize_t pktgen_if_write(struct file *file,
 		return count;
 	}
 
+	if (!strcmp(name, "spi")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+		if (len < 0)
+			return len;
+
+		i += len;
+		pkt_dev->spi = value;
+		sprintf(pg_result, "OK: spi=%u", pkt_dev->spi);
+		return count;
+	}
+
 	if (!strcmp(name, "flowlen")) {
 		len = num_arg(&user_buffer[i], 10, &value);
 		if (len < 0)
-- 
1.7.9.5
