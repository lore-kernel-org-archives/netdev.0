From: CAI Qian <caiqian@redhat.com>
Subject: [PATCH stable] ipv4: avoid passing NULL to inet_putpeer() in
 icmpv4_xrlim_allow()
Date: Fri, 7 Dec 2012 10:46:40 -0500 (EST)
Message-ID: <1443466888.5267673.1354895200559.JavaMail.root@redhat.com>
References: <1411074275.5265862.1354894974886.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:51664 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756400Ab2LGPqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 10:46:42 -0500
In-Reply-To: <1411074275.5265862.1354894974886.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, this patch looks applicable for the stable releases.

>From Neal Cardwell <ncardwell@google.com>

inet_getpeer_v4() can return NULL under OOM conditions, and while
inet_peer_xrlim_allow() is OK with a NULL peer, inet_putpeer() will
crash.

This code path now uses the same idiom as the others from:
1d861aa4b3fb08822055345f480850205ffe6170 ("inet: Minimize use of
cached route inetpeer.").

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

Upstream-ID: e1a676424c290b1c8d757e3860170ac7ecd89af4
Stable-trees: 3.6.x
Signed-off-by: CAI Qian <caiqian@redhat.com>

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f2eccd5..17ff9fd 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -257,7 +257,8 @@ static inline bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 		struct inet_peer *peer = inet_getpeer_v4(net->ipv4.peers, fl4->daddr, 1);
 		rc = inet_peer_xrlim_allow(peer,
 					   net->ipv4.sysctl_icmp_ratelimit);
-		inet_putpeer(peer);
+		if (peer)
+			inet_putpeer(peer);
 	}
 out:
 	return rc;
