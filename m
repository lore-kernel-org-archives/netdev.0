From: roy.qing.li@gmail.com
Subject: [PATCH] net/core: fix rollback handler in register_netdevice_notifier
Date: Thu,  1 Dec 2011 10:37:50 +0800
Message-ID: <1322707070-9514-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:63497 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925Ab1LACiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 21:38:01 -0500
Received: by ggnr5 with SMTP id r5so1342464ggn.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 18:38:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

Within nested statements, the break statement terminates only the
do, for, switch, or while statement that immediately encloses it,
So replace the break with goto.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/core/dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 278463e..88876fa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1387,7 +1387,7 @@ rollback:
 	for_each_net(net) {
 		for_each_netdev(net, dev) {
 			if (dev == last)
-				break;
+				goto outroll;
 
 			if (dev->flags & IFF_UP) {
 				nb->notifier_call(nb, NETDEV_GOING_DOWN, dev);
@@ -1398,6 +1398,7 @@ rollback:
 		}
 	}
 
+outroll:
 	raw_notifier_chain_unregister(&netdev_chain, nb);
 	goto unlock;
 }
-- 
1.7.1
