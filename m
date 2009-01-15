From: Phil Sutter <n0-1@freewrt.org>
Subject: [PATCH] korina: adjust headroom for new skb's also
Date: Thu, 15 Jan 2009 23:29:56 +0100
Message-ID: <20090115223020.A7EED4043838@mail.nwl.cc>
References: <1232058598-15811-1-git-send-email-n0-1@freewrt.org>
Cc: davem@davemloft.net, jeff@garzik.org, florian@openwrt.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:58491 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935348AbZAOWjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 17:39:42 -0500
In-Reply-To: <1232058598-15811-1-git-send-email-n0-1@freewrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is copy and paste from the original driver. As skb_reserve() is
also called within korina_alloc_ring() when initially allocating the
receive descriptors, the same should be done when allocating new space
after passing an skb to upper layers.

Signed-off-by: Phil Sutter <n0-1@freewrt.org>
---
 drivers/net/korina.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 67fbdf4..60ae7bf 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -416,6 +416,9 @@ static int korina_rx(struct net_device *dev, int limit)
 			if (devcs & ETH_RX_MP)
 				dev->stats.multicast++;
 
+			/* 16 bit align */
+			skb_reserve(skb_new, 2);
+
 			lp->rx_skb[lp->rx_next_done] = skb_new;
 		}
 
-- 
1.5.6.4

