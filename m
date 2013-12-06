From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 2/5] {pktgen, xfrm} Using "pgset spi xxx" to spedifiy SA for a given flow
Date: Fri, 6 Dec 2013 17:53:31 +0800
Message-ID: <1386323614-5077-3-git-send-email-fan.du@windriver.com>
References: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:55571 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757278Ab3LFJxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 04:53:43 -0500
In-Reply-To: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
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
index e6820e5..717e0b7 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -387,6 +387,7 @@ struct pktgen_dev {
 	int node;               /* Memory node */
 
 #ifdef CONFIG_XFRM
+	__u32 spi;
 #endif
 	char result[512];
 };
@@ -1474,6 +1475,16 @@ static ssize_t pktgen_if_write(struct file *file,
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
