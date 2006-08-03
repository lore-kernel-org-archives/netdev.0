From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] llc: multicast receive device match
Date: Thu, 3 Aug 2006 10:05:58 -0700
Message-ID: <20060803100558.72ff1863@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:37531 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964861AbWHCRGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 13:06:24 -0400
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix from Aji_Srinivas@emc.com, STP packets are incorrectly received on all
LLC datagram sockets, whichever interface they are bound to. 
The llc_sap datagram receive logic sends packets with a unicast destination 
MAC to one socket bound to that SAP and MAC, and multicast packets to all sockets
bound to that SAP. STP packets are multicast, and we do need to know
on which interface they were received.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/llc/llc_sap.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index 42eb0c3..61cb8cf 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -330,6 +330,9 @@ static void llc_sap_mcast(struct llc_sap
 		if (llc->laddr.lsap != laddr->lsap)
 			continue;
 
+		if (llc->dev != skb->dev)
+			continue;
+
 		skb1 = skb_clone(skb, GFP_ATOMIC);
 		if (!skb1)
 			break;
-- 
1.4.0


-- 
