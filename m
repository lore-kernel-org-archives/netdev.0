From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/4] openvswitch: Set inner-most protocol for MPLS.
Date: Mon,  1 Dec 2014 14:30:33 -0800
Message-ID: <1417473033-2136-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:40862 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932423AbaLAWag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 17:30:36 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so12003036pab.28
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 14:30:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPLS GSO needs to know inner most protocol to process GSO packets.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 764fdc3..770064c 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -147,7 +147,8 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	hdr = eth_hdr(skb);
 	hdr->h_proto = mpls->mpls_ethertype;
 
-	skb_set_inner_protocol(skb, skb->protocol);
+	if (!skb->inner_protocol)
+		skb_set_inner_protocol(skb, skb->protocol);
 	skb->protocol = mpls->mpls_ethertype;
 
 	invalidate_flow_key(key);
-- 
1.7.1
