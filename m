From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 10/15] ax25: Stop calling/abusing dev_rebuild_header
Date: Mon, 02 Mar 2015 00:08:43 -0600
Message-ID: <87pp8s6idw.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:41664 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbbCBGMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 01:12:16 -0500
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


- Rename ax25_rebuild_header to ax25_neigh_xmit and call it from
  ax25_neigh_output directly.  The rename is to make it clear
  that this is not a rebuild_header operation.

- Remove ax25_rebuild_header from ax25_header_ops.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-hams@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ax25/ax25_ip.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index cc7415b33cfb..08803e820f1d 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -100,7 +100,7 @@ static int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
 	return -AX25_HEADER_LEN;	/* Unfinished header */
 }
 
-static int ax25_rebuild_header(struct sk_buff *skb)
+static int ax25_neigh_xmit(struct sk_buff *skb)
 {
 	struct sk_buff *ourskb;
 	unsigned char *bp  = skb->data;
@@ -224,7 +224,7 @@ static int ax25_neigh_output(struct neighbour *neigh, struct sk_buff *skb)
 
 	if (dev_hard_header(skb, dev, ntohs(skb->protocol), NULL, NULL,
 			    skb->len) < 0 &&
-	    dev_rebuild_header(skb))
+	    ax25_neigh_xmit(skb));
 		return 0;
 
 	return dev_queue_xmit(skb);
@@ -255,11 +255,6 @@ static int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
 	return -AX25_HEADER_LEN;
 }
 
-static int ax25_rebuild_header(struct sk_buff *skb)
-{
-	return 1;
-}
-
 int ax25_neigh_construct(struct neighbour *neigh)
 {
 	return 0;
@@ -268,7 +263,6 @@ int ax25_neigh_construct(struct neighbour *neigh)
 
 const struct header_ops ax25_header_ops = {
 	.create = ax25_hard_header,
-	.rebuild = ax25_rebuild_header,
 };
 
 EXPORT_SYMBOL(ax25_header_ops);
-- 
2.2.1
