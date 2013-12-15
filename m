From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv3 net-next 4/7] {pktgen, xfrm} Using "pgset spi xxx" to spedifiy SA for a given flow
Date: Sun, 15 Dec 2013 15:58:01 +0800
Message-ID: <1387094284-2901-5-git-send-email-fan.du@windriver.com>
References: <1387094284-2901-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <steffen.klassert@secunet.com>, <hadi@cyberus.ca>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:38596 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648Ab3LOH61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 02:58:27 -0500
In-Reply-To: <1387094284-2901-1-git-send-email-fan.du@windriver.com>
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
index 156d57b..f663d96 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -389,6 +389,7 @@ struct pktgen_dev {
 #ifdef CONFIG_XFRM
 	__u8	ipsmode;		/* IPSEC mode (config) */
 	__u8	ipsproto;		/* IPSEC type (config) */
+	__u32 	spi;
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
