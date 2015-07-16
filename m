From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: [PATCH net-next] ipv6: Remove unused arguments for __ipv6_dev_get_saddr().
Date: Thu, 16 Jul 2015 16:51:30 +0900
Message-ID: <55A76282.9030806@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kvGyRCNUhGIzFRTEAbKEI=?=
	<hideaki.yoshifuji@miraclelinux.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33661 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbbGPHve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 03:51:34 -0400
Received: by pdbqm3 with SMTP id qm3so40000362pdb.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 00:51:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
---
 net/ipv6/addrconf.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4c9a024..32153c2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1360,8 +1360,6 @@ out:
 
 static int __ipv6_dev_get_saddr(struct net *net,
 				struct ipv6_saddr_dst *dst,
-				unsigned int prefs,
-				const struct in6_addr *saddr,
 				struct inet6_dev *idev,
 				struct ipv6_saddr_score *scores,
 				int hiscore_idx)
@@ -1485,13 +1483,13 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 
 	if (use_oif_addr) {
 		if (idev)
-			hiscore_idx = __ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, scores, hiscore_idx);
+			hiscore_idx = __ipv6_dev_get_saddr(net, &dst, idev, scores, hiscore_idx);
 	} else {
 		for_each_netdev_rcu(net, dev) {
 			idev = __in6_dev_get(dev);
 			if (!idev)
 				continue;
-			hiscore_idx = __ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, scores, hiscore_idx);
+			hiscore_idx = __ipv6_dev_get_saddr(net, &dst, idev, scores, hiscore_idx);
 		}
 	}
 	rcu_read_unlock();
-- 
1.9.1


-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
