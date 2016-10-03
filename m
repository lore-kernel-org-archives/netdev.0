From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] ipv6 addrconf: disallow rtr_solicits < -1
Date: Sun,  2 Oct 2016 23:41:57 -0700
Message-ID: <1475476917-17382-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36557 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751375AbcJCGmE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 02:42:04 -0400
Received: by mail-pa0-f67.google.com with SMTP id cd13so6223614pac.3
        for <netdev@vger.kernel.org>; Sun, 02 Oct 2016 23:42:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

This disallows setting /proc/sys/net/ipv6/conf/*/router_solicitations
to values below -1.

-1 continues to mean an unlimited number of retransmits.

Note: this depends on 'ipv6 addrconf: remove addrconf_sysctl_hop_limit()'

Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 net/ipv6/addrconf.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cbd9343751a2..511b76e6a50e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5729,6 +5729,7 @@ int addrconf_sysctl_ignore_routes_with_linkdown(struct ctl_table *ctl,
 	return ret;
 }
 
+static const int minus_one = -1;
 static const int one = 1;
 static const int two_five_five = 255;
 
@@ -5789,7 +5790,8 @@ static const struct ctl_table addrconf_sysctl[] = {
 		.data		= &ipv6_devconf.rtr_solicits,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void *)&minus_one,
 	},
 	{
 		.procname	= "router_solicitation_interval",
-- 
2.8.0.rc3.226.g39d4020
