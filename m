From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH 1/2] net: ipv6: af_inet6: Fix warning when CONFIG_SYSCTL=n
Date: Sat, 16 Nov 2013 00:52:07 -0200
Message-ID: <1384570328-21666-1-git-send-email-festevam@gmail.com>
Cc: netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:59719 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247Ab3KPCwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 21:52:32 -0500
Received: by mail-yh0-f44.google.com with SMTP id f73so2257981yha.31
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 18:52:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

When CONFIG_SYSCTL=n the following build warning happens:

net/ipv6/af_inet6.c:710:13: warning: 'ipv6_packet_cleanup' defined but not used [-Wunused-function]

ipv6_packet_cleanup() is only used when CONFIG_SYSCTL=y, so protect its 
definition with an'ifdef CONFIG_SYSCTL'.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 net/ipv6/af_inet6.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index ff75313..e4ad65c 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -707,10 +707,12 @@ static int __init ipv6_packet_init(void)
 	return 0;
 }
 
+#ifdef CONFIG_SYSCTL
 static void ipv6_packet_cleanup(void)
 {
 	dev_remove_pack(&ipv6_packet_type);
 }
+#endif
 
 static int __net_init ipv6_init_mibs(struct net *net)
 {
-- 
1.8.1.2
