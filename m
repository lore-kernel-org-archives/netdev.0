From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] ipv6: assign rt6_info to inet6_ifaddr in init_loopback
Date: Mon, 3 Jun 2013 16:16:21 +0800
Message-ID: <1370247381-3091-1-git-send-email-gaofeng@cn.fujitsu.com>
References: <201305290029.35303.a.miskiewicz@gmail.com>
Cc: netdev@vger.kernel.org, jasowang@redhat.com,
	kumaran.4353@gmail.com, Maruthi.Thotad@ap.sony.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:2733 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751312Ab3FCIOl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 04:14:41 -0400
In-Reply-To: <201305290029.35303.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
"net IPv6 : Fix broken IPv6 routing table after loopback down-up"
forgot to assign rt6_info to the inet6_ifaddr.
When disable the net device, the rt6_info which allocated
in init_loopback will not be destroied in __ipv6_ifa_notify.

This will trigger the waring message below
[23527.916091] unregister_netdevice: waiting for tap0 to become free. Usage count = 1

Reported-by: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/addrconf.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d1b2d80..1bbf744 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2658,8 +2658,10 @@ static void init_loopback(struct net_device *dev)
 			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, 0);
 
 			/* Failure cases are ignored */
-			if (!IS_ERR(sp_rt))
+			if (!IS_ERR(sp_rt)) {
+				sp_ifa->rt = sp_rt;
 				ip6_ins_rt(sp_rt);
+			}
 		}
 		read_unlock_bh(&idev->lock);
 	}
-- 
1.8.1.4
