From: yuan linyu <cugyly@163.com>
Subject: [PATCH] net: ioctl SIOCSIFADDR minor cleanup
Date: Tue, 15 Nov 2016 20:44:59 +0800
Message-ID: <1479213899-5952-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-133.163.com ([123.125.50.133]:38584 "EHLO m50-133.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751359AbcKOMpO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 07:45:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

1. set interface address label to ioctl request device name is enough
2. when address pass inet_abc_len check, prefixlen < 31 is always true

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/ipv4/devinet.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 062a67c..d491a7a 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1063,10 +1063,7 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 			if (!ifa)
 				break;
 			INIT_HLIST_NODE(&ifa->hash);
-			if (colon)
-				memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
-			else
-				memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
+			memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
 		} else {
 			ret = 0;
 			if (ifa->ifa_local == sin->sin_addr.s_addr)
@@ -1081,8 +1078,7 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		if (!(dev->flags & IFF_POINTOPOINT)) {
 			ifa->ifa_prefixlen = inet_abc_len(ifa->ifa_address);
 			ifa->ifa_mask = inet_make_mask(ifa->ifa_prefixlen);
-			if ((dev->flags & IFF_BROADCAST) &&
-			    ifa->ifa_prefixlen < 31)
+			if (dev->flags & IFF_BROADCAST)
 				ifa->ifa_broadcast = ifa->ifa_address |
 						     ~ifa->ifa_mask;
 		} else {
-- 
2.7.4
