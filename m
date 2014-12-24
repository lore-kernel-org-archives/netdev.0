From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 2/6] mpls: Fix allowed protocols for mpls gso
Date: Tue, 23 Dec 2014 16:20:16 -0800
Message-ID: <1419380416-1575-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:48693 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755294AbaLXAUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 19:20:23 -0500
Received: by mail-pd0-f178.google.com with SMTP id r10so8752098pdi.23
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 16:20:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPLS and Tunnel GSO does not work together.  Reject packet which
request such GSO.

Fixes: 0d89d2035f ("MPLS: Add limited GSO support").
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/mpls/mpls_gso.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index ca27837..349295d 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -31,10 +31,7 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 				  SKB_GSO_TCPV6 |
 				  SKB_GSO_UDP |
 				  SKB_GSO_DODGY |
-				  SKB_GSO_TCP_ECN |
-				  SKB_GSO_GRE |
-				  SKB_GSO_GRE_CSUM |
-				  SKB_GSO_IPIP)))
+				  SKB_GSO_TCP_ECN)))
 		goto out;
 
 	/* Setup inner SKB. */
-- 
1.7.1
