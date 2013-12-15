From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv3 net-next 7/7] {pktgen, xfrm} Show spi value properly when ipsec turned on
Date: Sun, 15 Dec 2013 15:58:04 +0800
Message-ID: <1387094284-2901-8-git-send-email-fan.du@windriver.com>
References: <1387094284-2901-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <steffen.klassert@secunet.com>, <hadi@cyberus.ca>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57058 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab3LOH6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 02:58:32 -0500
In-Reply-To: <1387094284-2901-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If user run pktgen plus ipsec by using spi, show spi value
properly when cat /proc/net/pktgen/ethX

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/core/pktgen.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index ae268ff..c7d1052 100644
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
