From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] netns: fix ip_rt_frag_needed rt_is_expired
Date: Sat, 26 Jul 2008 13:48:57 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0807261345400.6643@blonde.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Denis V. Lunev" <den@openvz.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from extu-mxob-1.symantec.com ([216.10.194.28]:41444 "EHLO
	extu-mxob-1.symantec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbYGZMuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 08:50:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running recent kernels, and using a particular vpn gateway, I've been
having to edit my mails down to get them accepted by the smtp server.

Git bisect led to commit e84f84f276473dcc673f360e8ff3203148bdf0e2 -
netns: place rt_genid into struct net.  The conversion from a != test
to rt_is_expired() put one negative too many: and now my mail works.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
Ingo was having strange distcc problems, might this help him too?

 net/ipv4/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 2.6.26-git/net/ipv4/route.c	2008-07-26 12:31:50.000000000 +0100
+++ linux/net/ipv4/route.c	2008-07-26 13:10:04.000000000 +0100
@@ -1502,7 +1502,7 @@ unsigned short ip_rt_frag_needed(struct 
 				    rth->fl.iif != 0 ||
 				    dst_metric_locked(&rth->u.dst, RTAX_MTU) ||
 				    !net_eq(dev_net(rth->u.dst.dev), net) ||
-				    !rt_is_expired(rth))
+				    rt_is_expired(rth))
 					continue;
 
 				if (new_mtu < 68 || new_mtu >= old_mtu) {
