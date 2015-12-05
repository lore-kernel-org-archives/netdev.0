From: Konstantin Shemyak <konstantin@shemyak.com>
Subject: [PATCH] Set DF bit for IPv4 GRE tunnels with fixed TTL
Date: Sat, 5 Dec 2015 22:55:13 +0200
Message-ID: <56634F31.3000609@shemyak.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub3.mail.dreamhost.com ([69.163.253.7]:51392 "EHLO
	homiemail-a12.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751055AbbLEUzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 15:55:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DF bit on IPv4 GRE tunnels with fixed TTL is enforced in order
to prevent networking loops. This was the original behavior of GRE
tunnels, lost in the refactoring.

Signed-off-by: Konstantin Shemyak <konstantin@shemyak.com>
---
  net/ipv4/ip_gre.c | 4 ++++
  1 file changed, 4 insertions(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6145214..485bf27 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -679,6 +679,10 @@ static int ipgre_tunnel_ioctl(struct net_device *dev,
  		    ((p.i_flags|p.o_flags)&(GRE_VERSION|GRE_ROUTING)))
  			return -EINVAL;
  	}
+
+        if (p.iph.ttl)
+                p.iph.frag_off |= htons(IP_DF);
+
  	p.i_flags = gre_flags_to_tnl_flags(p.i_flags);
  	p.o_flags = gre_flags_to_tnl_flags(p.o_flags);

-- 
1.9.1
