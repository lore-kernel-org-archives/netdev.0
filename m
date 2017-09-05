From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 rfc 7/8] net: dsa: set offload_fwd_mark on received packets
Date: Wed,  6 Sep 2017 01:35:09 +0200
Message-ID: <1504654510-31004-8-git-send-email-andrew@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Cc: jiri@resnulli.us, nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58199 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753475AbdIEXgE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 19:36:04 -0400
In-Reply-To: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The software bridge needs to know if a packet has already been bridged
by hardware offload to ports in the same hardware offload, in order
that it does not re-flood them, causing duplicates. This is
particularly true for multicast traffic which the host has required.

By setting offload_fwd_mark in the skb the bridge will only flood to
ports in other offloads and other netifs.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 03c58b0eb082..5732696ac71c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -213,6 +213,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb_push(skb, ETH_HLEN);
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, skb->dev);
+	skb->offload_fwd_mark = 1;
 
 	s = this_cpu_ptr(p->stats64);
 	u64_stats_update_begin(&s->syncp);
-- 
2.14.1
