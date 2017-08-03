From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 3/4] Revert "ipv4: keep skb->dst around in presence of IP options"
Date: Thu,  3 Aug 2017 18:07:07 +0200
Message-ID: <b00413bd89dcd925d22a7c245c2fe94edc9a2bd6.1501775813.git.pabeni@redhat.com>
References: <cover.1501775813.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58285 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751704AbdHCQHj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 12:07:39 -0400
In-Reply-To: <cover.1501775813.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_options_echo() does not use anymore the skb->dst and don't
need to keep the dst around for options's sake only.
This reverts commit 34b2cef20f19c87999fff3da4071e66937db9644.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/ip_sockglue.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 1c3354d028a4..dd68a9ed5e40 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1228,14 +1228,7 @@ void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
 		pktinfo->ipi_ifindex = 0;
 		pktinfo->ipi_spec_dst.s_addr = 0;
 	}
-	/* We need to keep the dst for __ip_options_echo()
-	 * We could restrict the test to opt.ts_needtime || opt.srr,
-	 * but the following is good enough as IP options are not often used.
-	 */
-	if (unlikely(IPCB(skb)->opt.optlen))
-		skb_dst_force(skb);
-	else
-		skb_dst_drop(skb);
+	skb_dst_drop(skb);
 }
 
 int ip_setsockopt(struct sock *sk, int level,
-- 
2.13.3
