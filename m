From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/13 net-3.1-stable] ipv4: avoid useless call of the
 function check_peer_pmtu
Date: Tue, 06 Dec 2011 16:33:33 -0500 (EST)
Message-ID: <20111206.163333.1488671593845696998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754638Ab1LFVdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:33:35 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6LXYKd024193
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 13:33:34 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Gao feng <gaofeng@cn.fujitsu.com>

[ Upstream commit 59445b6b1f90b97c4e28062b96306bacfa4fb170 ]

In func ipv4_dst_check,check_peer_pmtu should be called only when peer is updated.
So,if the peer is not updated in ip_rt_frag_needed,we can not inc __rt_peer_genid.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8b3661b..c3fcdb4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1572,11 +1572,10 @@ unsigned short ip_rt_frag_needed(struct net *net, const struct iphdr *iph,
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
1.7.7.3
