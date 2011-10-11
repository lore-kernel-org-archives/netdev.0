From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next] ipv6: Remove superfluous NULL pointer check in
 ipv6_local_rxpmtu
Date: Tue, 11 Oct 2011 14:01:02 +0200
Message-ID: <20111011120102.GL1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34565 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636Ab1JKMBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 08:01:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pointer to mtu_info is taken from the common buffer
of the skb, thus it can't be a NULL pointer. This patch
removes this check on mtu_info.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/datagram.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index b46e9f8..e248069 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -297,10 +297,6 @@ void ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu)
 	ipv6_addr_copy(&iph->daddr, &fl6->daddr);
 
 	mtu_info = IP6CBMTU(skb);
-	if (!mtu_info) {
-		kfree_skb(skb);
-		return;
-	}
 
 	mtu_info->ip6m_mtu = mtu;
 	mtu_info->ip6m_addr.sin6_family = AF_INET6;
-- 
1.7.0.4
