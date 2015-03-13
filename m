From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] vxlan: Don't set s_addr in vxlan_create_sock
Date: Fri, 13 Mar 2015 11:00:58 +0900
Message-ID: <1426212058-11224-1-git-send-email-simon.horman@netronome.com>
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Simon Horman <simon.horman@netronome.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:44584 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755393AbbCMCBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 22:01:24 -0400
Received: by padet14 with SMTP id et14so25244437pad.11
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 19:01:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case of AF_INET s_addr was set to INADDR_ANY (0) which which both
symmetric with the AF_INET6 case, where s_addr is not set, and unnecessary
as udp_conf is zeroed out earlier in the same function.

I suspect this change does not have any run-time effect due to compiler
optimisations. But it does make the code a little easier on the/my eyes.

Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
* Found by inspection, lightly tested
---
 drivers/net/vxlan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1e0a775..25d92d4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2516,7 +2516,6 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 		    !(flags & VXLAN_F_UDP_ZERO_CSUM6_RX);
 	} else {
 		udp_conf.family = AF_INET;
-		udp_conf.local_ip.s_addr = INADDR_ANY;
 	}
 
 	udp_conf.local_udp_port = port;
-- 
2.1.4
