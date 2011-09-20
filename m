From: Kasper Pedersen <kernel@kasperkp.dk>
Subject: [PATCH] tg3: fix VLAN tagging regression
Date: Tue, 20 Sep 2011 22:48:56 +0200
Message-ID: <4E78FC38.7040903@kasperkp.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n1.taur.dk ([217.198.219.102]:35328 "EHLO n1.taur.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763Ab1ITVZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 17:25:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 92cd3a17ce9c719abb4c28dee3438e0c641f8de4
    tg3: Simplify tx bd assignments

broke VLAN tagging on outbound packets.
It ifdef'ed BCM_KERNEL_SUPPORTS_8021Q, but this
is not set anywhere. So vlan never gets set, and
all packets are sent with vlan=0.

Change to use the CONFIG_VLAN_xxx defines instead.
Tested on BCM5721 rev 11.

Signed-off-by: Kasper Pedersen <kernel@kasperkp.dk>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index dc3fbf6..a00d21b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6234,7 +6234,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-#ifdef BCM_KERNEL_SUPPORTS_8021Q
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 	if (vlan_tx_tag_present(skb)) {
 		base_flags |= TXD_FLAG_VLAN;
 		vlan = vlan_tx_tag_get(skb);
