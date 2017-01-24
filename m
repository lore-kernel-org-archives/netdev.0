From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 5/5] gtp: let userspace handle packets for invalid tunnels
Date: Tue, 24 Jan 2017 18:24:02 +0100
Message-ID: <20170124172402.12096-6-aschultz@tpip.net>
References: <20170124172402.12096-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:45761 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750786AbdAXRYK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 12:24:10 -0500
In-Reply-To: <20170124172402.12096-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enable userspace to send error replies for invalid tunnels

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 912721e..c607333 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -198,12 +198,12 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
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
@@ -247,12 +247,12 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
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
