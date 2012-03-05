From: Alexandru Juncu <ajuncu@ixiacom.com>
Subject: [PATCH] ipv6: fix socket multicast check
Date: Mon,  5 Mar 2012 20:12:09 +0200
Message-ID: <1330971129-10781-1-git-send-email-ajuncu@ixiacom.com>
Cc: alexj@rosedu.org, Alexandru Juncu <ajuncu@ixiacom.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47351 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756616Ab2CESNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 13:13:04 -0500
Received: by eaaq12 with SMTP id q12so1534300eaa.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 10:13:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes an issue where multicast packets are delivered for
sockets which didn't join any multicast groups.

The issue was discovered because Hello packets duplicates were
received in OSPFv3.

Signed-off-by: Alexandru Juncu <ajuncu@ixiacom.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>
---
 net/ipv6/mcast.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index b853f06..10cc72f 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -622,7 +622,7 @@ int inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
 	}
 	if (!mc) {
 		rcu_read_unlock();
-		return 1;
+		return 0;
 	}
 	read_lock(&mc->sflock);
 	psl = mc->sflist;
-- 
1.7.5.4
