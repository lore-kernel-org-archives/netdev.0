From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv4 net-next 4/8] {pktgen, xfrm} Using "pgset spi xxx" to spedifiy SA for a given flow
Date: Fri, 3 Jan 2014 11:18:30 +0800
Message-ID: <1388719114-26244-5-git-send-email-fan.du@windriver.com>
References: <1388719114-26244-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47830 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753631AbaACDSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 22:18:44 -0500
In-Reply-To: <1388719114-26244-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

User could set specific SPI value to arm pktgen flow with IPsec
transformation, instead of looking up SA by sadr/daddr. The reaseon
to do so is because current state lookup scheme is both slow and, most
important of all, in fact pktgen doesn't need to match any SA state
addresses information, all it needs is the SA transfromation shell to
do the encapuslation.

And this option also provide user an alternative to using pktgen
test existing SA without creating new ones.

Signed-off-by: Fan Du <fan.du@windriver.com>
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
