From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH v2 13/18] gtp: replace netdev_dbg and KERN_DEBUG printk with pr_debug
Date: Tue, 24 Jan 2017 16:28:43 +0100
Message-ID: <20170124152848.6120-14-aschultz@tpip.net>
References: <20170124152848.6120-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:35219 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751147AbdAXP26 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 10:28:58 -0500
In-Reply-To: <20170124152848.6120-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pr_debug is more versatile for normal debugging.
Also replace netdev_dbg in in places where the network device
will be remove soon.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 8d74b7d..7d82252 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -235,7 +235,7 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 
 	pctx = gtp0_pdp_find(gtp, be64_to_cpu(gtp0->tid));
 	if (IS_ERR(pctx)) {
-		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
+		pr_debug("No PDP ctx to decap skb=%p\n", skb);
 		return 1;
 	}
 
@@ -277,7 +277,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 
 	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
 	if (IS_ERR(pctx)) {
-		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
+		pr_debug("No PDP ctx to decap skb=%p\n", skb);
 		return 1;
 	}
 
@@ -296,15 +296,15 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!gtp)
 		return 1;
 
-	netdev_dbg(gtp->dev, "encap_recv sk=%p\n", sk);
+	pr_debug("encap_recv sk=%p\n", sk);
 
 	switch (udp_sk(sk)->encap_type) {
 	case UDP_ENCAP_GTP0:
-		netdev_dbg(gtp->dev, "received GTP0 packet\n");
+		pr_debug("received GTP0 packet\n");
 		ret = gtp0_udp_encap_recv(gtp, skb);
 		break;
 	case UDP_ENCAP_GTP1U:
-		netdev_dbg(gtp->dev, "received GTP1U packet\n");
+		pr_debug("received GTP1U packet\n");
 		ret = gtp1u_udp_encap_recv(gtp, skb);
 		break;
 	default:
@@ -313,12 +313,12 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	switch (ret) {
 	case 1:
-		netdev_dbg(gtp->dev, "pass up to the process\n");
+		pr_debug("pass up to the process\n");
 		break;
 	case 0:
 		break;
 	case -1:
-		netdev_dbg(gtp->dev, "GTP packet has been dropped\n");
+		pr_debug("GTP packet has been dropped\n");
 		kfree_skb(skb);
 		ret = 0;
 		break;
-- 
2.10.2
