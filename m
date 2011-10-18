From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] route:ip_rt_frag_needed always return unzero
Date: Tue, 18 Oct 2011 15:04:29 +0800
Message-ID: <1318921469-25599-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49490 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753243Ab1JRHEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Oct 2011 03:04:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

int function ip_rt_frag_need,if peer is null,
there is no need to do ipprot->err_handler.
I am right?

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 075212e..6cde0fa 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1574,7 +1574,7 @@ unsigned short ip_rt_frag_needed(struct net *net, const struct iphdr *iph,
 
 		atomic_inc(&__rt_peer_genid);
 	}
-	return est_mtu ? : new_mtu;
+	return est_mtu;
 }
 
 static void check_peer_pmtu(struct dst_entry *dst, struct inet_peer *peer)
-- 
1.7.1
