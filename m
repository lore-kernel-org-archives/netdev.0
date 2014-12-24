From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 4/6] openvswitch: Fix GSO with multiple MPLS label.
Date: Tue, 23 Dec 2014 16:20:28 -0800
Message-ID: <1419380428-1635-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:60459 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755294AbaLXAUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 19:20:31 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so8820712pdi.21
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 16:20:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPLS GSO needs to know inner most protocol to process GSO packets.

Fixes: 25cd9ba0abc ("openvswitch: Add basic MPLS support to
kernel").

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
