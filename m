From: Mazhar Rana <ranamazharp@gmail.com>
Subject: [PATCH ipv6 1/1] ipv6: addrconf: do addrconf_ifdown when last ipv6 address is removed
Date: Thu, 18 Jun 2015 14:59:02 +0530
Message-ID: <1434619742-10423-2-git-send-email-ranamazharp@gmail.com>
References: <1434619742-10423-1-git-send-email-ranamazharp@gmail.com>
Cc: Mazhar Rana <ranamazharp@gmail.com>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, sanket.saha@cyberoam.com,
	mazhar.rana@cyberoam.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36378 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792AbbFRJan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 05:30:43 -0400
In-Reply-To: <1434619742-10423-1-git-send-email-ranamazharp@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After 'commit 876fd05ddbae03166e7037fca957b55bb3be6594
("ipv6: don't disable interface if last ipv6 address is removed")'
it is not clearing ipv6 interface configurations(routes, neighbours,
etc) when last ipv6 address of interface is removed.

This patch will call addrconf_ifdown when last ipv6 address of
interface is removed to clear ipv6 interface configurations. This will
not delete /proc/sys/net/ipv6/conf/<interface> directory.

Signed-off-by: Mazhar Rana <mazhar.rana@cyberoam.com>
Acked-by: Sanket Shah <sanket.shah@cyberoam.com>
---
 net/ipv6/addrconf.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 37b70e8..230452c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2678,6 +2678,8 @@ static int inet6_addr_del(struct net *net, int ifindex, u32 ifa_flags,
 				ipv6_mc_config(net->ipv6.mc_autojoin_sk,
 					       false, pfx, dev->ifindex);
 			}
+			if (list_empty(&idev->addr_list))
+				addrconf_ifdown(idev->dev, 0);
 			return 0;
 		}
 	}
-- 
1.9.1
