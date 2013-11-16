From: Vlad Yasevich <vyasevich@gmail.com>
Subject: [PATCHv2] ipv6: Fix inet6_init() cleanup order
Date: Sat, 16 Nov 2013 15:17:24 -0500
Message-ID: <1384633044-26453-1-git-send-email-vyasevich@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Lorenzo Colitti <lorenzo@google.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:44713 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785Ab3KPURe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 15:17:34 -0500
Received: by mail-qa0-f41.google.com with SMTP id k4so1375419qaq.0
        for <netdev@vger.kernel.org>; Sat, 16 Nov 2013 12:17:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6d0bfe22611602f36617bc7aa2ffa1bbb2f54c67
	net: ipv6: Add IPv6 support to the ping socket

introduced a change in the cleanup logic of inet6_init and
has a bug in that ipv6_packet_cleanup() may not be called.
Fix the cleanup ordering.

CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
CC: Lorenzo Colitti <lorenzo@google.com>
CC: Fabio Estevam <fabio.estevam@freescale.com>
Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
---
 net/ipv6/af_inet6.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 6468bda..56ca35b 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -958,10 +958,10 @@ out:
 
 #ifdef CONFIG_SYSCTL
 sysctl_fail:
-	ipv6_packet_cleanup();
+	pingv6_exit();
 #endif
 pingv6_fail:
-	pingv6_exit();
+	ipv6_packet_cleanup();
 ipv6_packet_fail:
 	tcpv6_exit();
 tcpv6_fail:
-- 
1.8.4.2
