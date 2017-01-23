From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 12/17] gtp: let userspace handle packets for invalid tunnels
Date: Mon, 23 Jan 2017 12:57:01 +0100
Message-ID: <20170123115706.4354-13-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:42814 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750997AbdAWMGy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:54 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enable userspace to send error replies for invalid tunnels

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 868467d..290c400 100644
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
