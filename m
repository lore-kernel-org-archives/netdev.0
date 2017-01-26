From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v2 2/2] gtp: let userspace handle packets for invalid tunnels
Date: Thu, 26 Jan 2017 16:21:49 +0100
Message-ID: <20170126152149.3284-3-aschultz@tpip.net>
References: <20170126152149.3284-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>,
        SF Markus Elfring <elfring@users.sourceforge.net>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:40135 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753218AbdAZPV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 10:21:56 -0500
In-Reply-To: <20170126152149.3284-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enable userspace to send error replies for invalid tunnels

Acked-by: Harald Welte <laforge@netfilter.org>
Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 5c63a37..5dd7de6 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -199,12 +199,12 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 	pctx = gtp0_pdp_find(gtp, be64_to_cpu(gtp0->tid));
 	if (!pctx) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
-		return -1;
+		return 1;
 	}
 
 	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
 		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
-		return -1;
+		return 1;
 	}
 
 	/* Get rid of the GTP + UDP headers. */
@@ -248,12 +248,12 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
 	if (!pctx) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
-		return -1;
+		return 1;
 	}
 
 	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
 		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
-		return -1;
+		return 1;
 	}
 
 	/* Get rid of the GTP + UDP headers. */
-- 
2.10.2
