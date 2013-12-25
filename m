From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] sctp: check dst 'NULL' before use it in, sctp_packet_transmit
Date: Wed, 25 Dec 2013 15:47:46 +0800
Message-ID: <52BA8DA2.6030405@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:39229 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab3LYHsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 02:48:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_dst_set will use dst, if dst is NULL although is not a problem,
then goto the no_route and free nskb, so do the skb_dst_set is pointless.
so check dst before use it. Remove the unnecessary initialization as well.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/output.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 3be70a4..9b76d62 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -387,7 +387,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	int err = 0;
 	int padding;		/* How much padding do we need?  */
 	__u8 has_data = 0;
-	struct dst_entry *dst = tp->dst;
+	struct dst_entry *dst;
 	unsigned char *auth = NULL;	/* pointer to auth in skb data */
 
 	pr_debug("%s: packet:%p\n", __func__, packet);
@@ -420,9 +420,9 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 		}
 	}
 	dst = dst_clone(tp->dst);
-	skb_dst_set(nskb, dst);
 	if (!dst)
 		goto no_route;
+	skb_dst_set(nskb, dst);
 
 	/* Build the SCTP header.  */
 	sh = (struct sctphdr *)skb_push(nskb, sizeof(struct sctphdr));
-- 
1.7.12
