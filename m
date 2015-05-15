From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipip: fix one sparse error
Date: Fri, 15 May 2015 08:58:45 -0700
Message-ID: <1431705525.27831.109.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37958 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754698AbbEOP6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 11:58:46 -0400
Received: by igcau1 with SMTP id au1so31879381igc.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 08:58:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/ipip.o
  CHECK   net/ipv4/ipip.c
net/ipv4/ipip.c:254:27: warning: incorrect type in assignment (different base types)
net/ipv4/ipip.c:254:27:    expected restricted __be32 [addressable] [usertype] o_key
net/ipv4/ipip.c:254:27:    got restricted __be16 [addressable] [usertype] i_flags

Fixes: 3b7b514f44bf ("ipip: fix a regression in ioctl")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ipip.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index ff96396ebec5bdf794cf84776f21505d0b7de737..254238daf58bd9f6e398609b67ca6a0b946600d2 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -251,7 +251,8 @@ ipip_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return -EINVAL;
 	}
 
-	p.i_key = p.o_key = p.i_flags = p.o_flags = 0;
+	p.i_key = p.o_key = 0;
+	p.i_flags = p.o_flags = 0;
 	if (p.iph.ttl)
 		p.iph.frag_off |= htons(IP_DF);
 
