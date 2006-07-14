From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] clear skb cb on IP input
Date: Fri, 14 Jul 2006 11:56:21 -0700
Message-ID: <20060714115621.689cd7a0@dxpl.pdx.osdl.net>
References: <44B7AB76.2030700@yahoo.fr>
	<20060714083847.6997a460@localhost.localdomain>
	<44B7CE81.8020800@yahoo.fr>
	<20060714113900.029e6a2f@dxpl.pdx.osdl.net>
	<44B7E740.5090004@yahoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Guillaume Chazarain <guichaz@yahoo.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31201 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161290AbWGNS4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 14:56:23 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <44B7E740.5090004@yahoo.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

when data arrives at IP through loopback (and possibly other devices).
So the field needs to be cleared before it confuses the route code.
This was seen when running netem over loopback, but there are probably
other device cases. Maybe this should go into stable?

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/ipv4/ip_input.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index e1a7dba..184c78c 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -428,6 +428,9 @@ int ip_rcv(struct sk_buff *skb, struct n
 		goto drop;
 	}
 
+	/* Remove any debris in the socket control block */
+	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
+
 	return NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, dev, NULL,
 		       ip_rcv_finish);
 
-- 
1.4.0

