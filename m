From: Fan Du <fan.du@windriver.com>
Subject: [PATCH RFC 2/5] {pktgen, xfrm} Using "pgset spi xxx" to spedifiy SA for a given flow
Date: Thu, 5 Dec 2013 15:57:16 +0800
Message-ID: <1386230239-31860-3-git-send-email-fan.du@windriver.com>
References: <1386230239-31860-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62067 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339Ab3LEH51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 02:57:27 -0500
In-Reply-To: <1386230239-31860-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

User could set specific SPI value to arm pktgen flow with IPsec
transformation, instead of looking up SA by sadr/daddr. The reaseon
to do so is because current state lookup scheme is both slow and, most
important of all, in fact pktgen doesn't need to match any SA state
addresses information, all it needs is the SA transfromation shell to
do the encapuslation.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/core/pktgen.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index ab67986..3e0a00f 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -387,6 +387,7 @@ struct pktgen_dev {
 	int node;               /* Memory node */
 
 #ifdef CONFIG_XFRM
+	__u32 spi;
 
 #endif
 	char result[512];
@@ -1475,6 +1476,16 @@ static ssize_t pktgen_if_write(struct file *file,
 		sprintf(pg_result, "OK: flows=%u", pkt_dev->cflows);
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
 
 	if (!strcmp(name, "flowlen")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-- 
1.7.9.5
