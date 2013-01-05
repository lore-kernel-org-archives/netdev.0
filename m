From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH] ipv4: fix NULL checking in devinet_ioctl()
Date: Sat,  5 Jan 2013 16:19:24 -0500
Message-ID: <1357420764-12381-1-git-send-email-xi.wang@gmail.com>
Cc: netdev@vger.kernel.org, Xi Wang <xi.wang@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:46930 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850Ab3AEVTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 16:19:31 -0500
Received: by mail-vc0-f176.google.com with SMTP id fo13so17762188vcb.35
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2013 13:19:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NULL pointer check `!ifa' should come before its first use.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 net/ipv4/devinet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cc06a47..a8e4f26 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -823,9 +823,9 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		if (!ifa) {
 			ret = -ENOBUFS;
 			ifa = inet_alloc_ifa();
-			INIT_HLIST_NODE(&ifa->hash);
 			if (!ifa)
 				break;
+			INIT_HLIST_NODE(&ifa->hash);
 			if (colon)
 				memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
 			else
-- 
1.7.10.4
