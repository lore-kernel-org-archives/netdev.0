From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 3/4] mpls: Fix allowed protocols for mpls gso
Date: Mon,  1 Dec 2014 14:30:42 -0800
Message-ID: <1417473042-2194-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:37726 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932423AbaLAWap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 17:30:45 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so11990778pad.37
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 14:30:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPLS and Tunnel GSO does not work together.  Reject packet which
request such GSO.

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
