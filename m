From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/6] net: dsa: {e}dsa: set offload_fwd_mark on received packets
Date: Wed, 27 Sep 2017 00:25:59 +0200
Message-ID: <1506464764-12699-3-git-send-email-andrew@lunn.ch>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:57027 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S969562AbdIZW2l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 18:28:41 -0400
In-Reply-To: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The software bridge needs to know if a packet has already been bridged
by hardware offload to ports in the same hardware offload, in order
that it does not re-flood them, causing duplicates. This is
particularly true for broadcast and multicast traffic which the host
has requested.

By setting offload_fwd_mark in the skb the bridge will only flood to
ports in other offloads and other netifs. Set this flag in the DSA and
EDSA tag driver.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---

v2
--
For the moment, do this in the tag drivers, not the generic code.
Once we get more test results from other switches, maybe move it back
again.
---
 net/dsa/tag_dsa.c  | 1 +
 net/dsa/tag_edsa.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index fbf9ca954773..ea6ada9d5016 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -154,6 +154,7 @@ static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	skb->dev = ds->ports[source_port].netdev;
+	skb->offload_fwd_mark = 1;
 
 	return skb;
 }
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 76367ba1b2e2..a961b22a7018 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -173,6 +173,7 @@ static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	skb->dev = ds->ports[source_port].netdev;
+	skb->offload_fwd_mark = 1;
 
 	return skb;
 }
-- 
2.14.1
