From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net v3 2/3] gtp: clear DF bit on GTP packet tx
Date: Fri, 27 Jan 2017 10:40:57 +0100
Message-ID: <20170127094058.7899-3-aschultz@tpip.net>
References: <20170127094058.7899-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>,
        SF Markus Elfring <elfring@users.sourceforge.net>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:48882 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932460AbdA0JlL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 04:41:11 -0500
In-Reply-To: <20170127094058.7899-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3GPP TS 29.281 and 3GPP TS 29.060 imply that GTP-U packets should be
sent with the DF bit cleared. For example 3GPP TS 29.060, Release 8,
Section 13.2.2:

> Backbone router: Any router in the backbone may fragment the GTP
> packet if needed, according to IPv4.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
Acked-by: Harald Welte <laforge@netfilter.org>
Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 drivers/net/gtp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 7580ccc..1df54d6 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -612,7 +612,7 @@ static netdev_tx_t gtp_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 				    pktinfo.fl4.saddr, pktinfo.fl4.daddr,
 				    pktinfo.iph->tos,
 				    ip4_dst_hoplimit(&pktinfo.rt->dst),
-				    htons(IP_DF),
+				    0,
 				    pktinfo.gtph_port, pktinfo.gtph_port,
 				    true, false);
 		break;
-- 
2.10.2
