From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] pptp: lookup route with the proper net namespace
Date: Tue, 7 Aug 2012 18:23:11 +0800
Message-ID: <1344334991-3441-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:20427 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751170Ab2HGKmc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 06:42:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pptp always use init_net as the net namespace to lookup
route, this will cause route lookup failed in container.

because we already set the correct net namespace to struct
sock in pptp_create,so fix this by using sock_net(sk) to
replace &init_net.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/net/ppp/pptp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 1c98321..162464f 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -189,7 +189,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	if (sk_pppox(po)->sk_state & PPPOX_DEAD)
 		goto tx_error;
 
-	rt = ip_route_output_ports(&init_net, &fl4, NULL,
+	rt = ip_route_output_ports(sock_net(sk), &fl4, NULL,
 				   opt->dst_addr.sin_addr.s_addr,
 				   opt->src_addr.sin_addr.s_addr,
 				   0, 0, IPPROTO_GRE,
@@ -468,7 +468,7 @@ static int pptp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	po->chan.private = sk;
 	po->chan.ops = &pptp_chan_ops;
 
-	rt = ip_route_output_ports(&init_net, &fl4, sk,
+	rt = ip_route_output_ports(sock_net(sk), &fl4, sk,
 				   opt->dst_addr.sin_addr.s_addr,
 				   opt->src_addr.sin_addr.s_addr,
 				   0, 0,
-- 
1.7.7.6
