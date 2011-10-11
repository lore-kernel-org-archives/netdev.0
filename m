From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/4] ipv4: Fix inetpeer expiration handling
Date: Tue, 11 Oct 2011 13:11:22 +0200
Message-ID: <20111011111122.GF1830@secunet.com>
References: <20111011110842.GC1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57886 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753776Ab1JKLL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 07:11:26 -0400
Content-Disposition: inline
In-Reply-To: <20111011110842.GC1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We leak a trigger to check if the learned pmtu information has
expired, so the learned pmtu informations never expire. This patch
add such a trigger to ipv4_dst_check().

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9a6623e..cda370c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1660,6 +1660,10 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 
 	if (rt_is_expired(rt))
 		return NULL;
+
+	if (rt->peer && peer_pmtu_expired(rt->peer))
+		dst_metric_set(dst, RTAX_MTU, rt->peer->pmtu_orig);
+
 	if (rt->rt_peer_genid != rt_peer_genid()) {
 		struct inet_peer *peer;
 
-- 
1.7.0.4
