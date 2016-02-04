From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 13/13] net: Allow IPsec GSO for locally sent traffic.
Date: Thu, 4 Feb 2016 07:37:06 +0100
Message-ID: <1454567826-13018-14-git-send-email-steffen.klassert@secunet.com>
References: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36681 "EHLO
	h-62.96.220.36.host.de.colt.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755994AbcBDHFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:05:50 -0500
In-Reply-To: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch finally allows locally sent IPsec packets to
use the GSO codepath.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/core/sock.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 6c1c8bc..8fca8b0 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1583,13 +1583,9 @@ void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 		sk->sk_route_caps |= NETIF_F_GSO_SOFTWARE;
 	sk->sk_route_caps &= ~sk->sk_route_nocaps;
 	if (sk_can_gso(sk)) {
-		if (dst->header_len) {
-			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
-		} else {
-			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
-			sk->sk_gso_max_size = dst->dev->gso_max_size;
-			max_segs = max_t(u32, dst->dev->gso_max_segs, 1);
-		}
+		sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
+		sk->sk_gso_max_size = dst->dev->gso_max_size;
+		max_segs = max_t(u32, dst->dev->gso_max_segs, 1);
 	}
 	sk->sk_gso_max_segs = max_segs;
 }
-- 
1.9.1
