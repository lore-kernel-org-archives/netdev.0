From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 12/15] {pktgen, xfrm} Show spi value properly when ipsec turned on
Date: Tue, 14 Jan 2014 07:49:16 +0100
Message-ID: <1389682159-3260-13-git-send-email-steffen.klassert@secunet.com>
References: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60110 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458AbaANGtl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:49:41 -0500
In-Reply-To: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

If user run pktgen plus ipsec by using spi, show spi value
properly when cat /proc/net/pktgen/ethX

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/core/pktgen.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b553c36..45ba476 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -657,8 +657,11 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	}
 
 #ifdef CONFIG_XFRM
-	if (pkt_dev->flags & F_IPSEC_ON)
+	if (pkt_dev->flags & F_IPSEC_ON) {
 		seq_printf(seq,  "IPSEC  ");
+		if (pkt_dev->spi)
+			seq_printf(seq, "spi:%u", pkt_dev->spi);
+	}
 #endif
 
 	if (pkt_dev->flags & F_MACSRC_RND)
-- 
1.7.9.5
