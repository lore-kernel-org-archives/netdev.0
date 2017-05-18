From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: [PATCH v2 1/4] arp: fixed error in a comment
Date: Thu, 18 May 2017 12:41:18 -0700
Message-ID: <e5f5c7e601bbc644f6a42ea1574170f81450ca44.1495136258.git.ihrachys@redhat.com>
References: <cover.1495136258.git.ihrachys@redhat.com>
Cc: Ihar Hrachyshka <ihrachys@redhat.com>, netdev@vger.kernel.org
To: davem@davemloft.net, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51600 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932285AbdERTli (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 15:41:38 -0400
In-Reply-To: <cover.1495136258.git.ihrachys@redhat.com>
In-Reply-To: <cover.1495136258.git.ihrachys@redhat.com>
References: <cover.1495136258.git.ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the is_garp code deals just with gratuitous ARP packets, not every
unsolicited packet.

This patch is a result of a discussion in netdev:
http://marc.info/?l=linux-netdev&m=149506354216994

Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>
---
 net/ipv4/arp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index d54345a..053492a 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -846,7 +846,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 		 */
 		is_garp = tip == sip && addr_type == RTN_UNICAST;
 
-		/* Unsolicited ARP _replies_ also require target hwaddr to be
+		/* Gratuitous ARP _replies_ also require target hwaddr to be
 		 * the same as source.
 		 */
 		if (is_garp && arp->ar_op == htons(ARPOP_REPLY))
-- 
2.9.3
