From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/4] vlan: Fix mac_len adjustment.
Date: Mon,  1 Dec 2014 14:30:38 -0800
Message-ID: <1417473038-2165-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:46233 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932669AbaLAWaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 17:30:46 -0500
Received: by mail-pd0-f178.google.com with SMTP id g10so11710015pdj.23
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 14:30:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_reset_mac_len() sets length according to ethernet and network
offsets, but mpls expects mac-length to be offset to mpls header (ref.
skb_mpls_header()). Therefore rather than reset we need to subtract
VLAN_HLEN from mac_len.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/core/skbuff.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 92116df..c45888f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4178,7 +4178,7 @@ static int __skb_vlan_pop(struct sk_buff *skb, u16 *vlan_tci)
 	if (skb_network_offset(skb) < ETH_HLEN)
 		skb_set_network_header(skb, ETH_HLEN);
 
-	skb_reset_mac_len(skb);
+	skb->mac_len -= VLAN_HLEN;
 pull:
 	__skb_pull(skb, offset);
 
-- 
1.7.1
