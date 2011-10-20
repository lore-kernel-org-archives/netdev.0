From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] ipv4: avoid useless call of the function check_peer_pmtu
Date: Thu, 20 Oct 2011 09:34:09 +0800
Message-ID: <1319074449-10892-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49321 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755839Ab1JTBdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 21:33:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In func ipv4_dst_check,check_peer_pmtu should be called only when peer is updated.
So,if the peer is not updated in ip_rt_frag_needed,we can not inc __rt_peer_genid.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/route.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 075212e..04a14db 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1568,11 +1568,10 @@ unsigned short ip_rt_frag_needed(struct net *net, const struct iphdr *iph,
 			est_mtu = mtu;
 			peer->pmtu_learned = mtu;
 			peer->pmtu_expires = pmtu_expires;
+			atomic_inc(&__rt_peer_genid);
 		}
 
 		inet_putpeer(peer);
-
-		atomic_inc(&__rt_peer_genid);
 	}
 	return est_mtu ? : new_mtu;
 }
-- 
1.7.1
