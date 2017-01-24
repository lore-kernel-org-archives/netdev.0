From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH v2 12/18] gtp: let userspace handle packets for invalid tunnels
Date: Tue, 24 Jan 2017 16:28:42 +0100
Message-ID: <20170124152848.6120-13-aschultz@tpip.net>
References: <20170124152848.6120-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:54179 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751184AbdAXP3B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 10:29:01 -0500
In-Reply-To: <20170124152848.6120-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enable userspace to send error replies for invalid tunnels

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index ea97b49..8d74b7d 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -186,7 +186,7 @@ static int gtp_rx(struct sk_buff *skb, struct pdp_ctx *pctx, unsigned int hdrlen
 
 	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
 		pr_debug("No PDP ctx for this MS\n");
-		return -1;
+		return 1;
 	}
 
 	/* Get rid of the GTP + UDP headers. */
@@ -236,7 +236,7 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 	pctx = gtp0_pdp_find(gtp, be64_to_cpu(gtp0->tid));
 	if (IS_ERR(pctx)) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
-		return -1;
+		return 1;
 	}
 
 	return gtp_rx(skb, pctx, hdrlen);
@@ -278,7 +278,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
 	if (IS_ERR(pctx)) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
-		return -1;
+		return 1;
 	}
 
 	return gtp_rx(skb, pctx, hdrlen);
-- 
2.10.2
