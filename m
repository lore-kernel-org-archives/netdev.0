From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] vxlan: insert ipv6 macro
Date: Tue, 11 Oct 2016 16:23:31 +0800
Message-ID: <1476174211-9358-1-git-send-email-zyjzyj2000@gmail.com>
To: netdev@vger.kernel.org, pabeni@redhat.com, daniel@iogearbox.net,
        pshelar@nicira.com, aduyck@mirantis.com,
        hannes@stressinduktion.org, jbenc@redhat.com, davem@davemloft.net,
        zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [123.118.58.201] ([123.118.58.201]:57428 "EHLO mail.rain.com"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751335AbcJKNWF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Oct 2016 09:22:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

The source code is related with ipv6. As such, it is better to insert
ipv6 macro.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/vxlan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e7d1668..9af6600 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2647,15 +2647,15 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 	int err;
 
 	memset(&udp_conf, 0, sizeof(udp_conf));
-
+#if IS_ENABLED(CONFIG_IPV6)
 	if (ipv6) {
 		udp_conf.family = AF_INET6;
 		udp_conf.use_udp6_rx_checksums =
 		    !(flags & VXLAN_F_UDP_ZERO_CSUM6_RX);
 		udp_conf.ipv6_v6only = 1;
-	} else {
+	} else 
+#endif
 		udp_conf.family = AF_INET;
-	}
 
 	udp_conf.local_udp_port = port;
 
-- 
2.7.4
