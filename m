From: Rami Rosen <rosenr@marvell.com>
Subject: [PATCH 1/1] net: fix documentation of skb_needs_linearize().
Date: Tue, 28 Aug 2012 12:39:24 +0300
Message-ID: <1346146764-23516-1-git-send-email-rosenr@marvell.com>
Cc: netdev@vger.kernel.org, Rami Rosen <rosenr@marvell.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:48869 "EHLO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751203Ab2H1JmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 05:42:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_needs_linearize() does not check highmem DMA as it does not call
illegal_highdma() anymore, so there is no need to mention highmem DMA here.

(Indeed, ~NETIF_F_SG flag, which is checked in skb_needs_linearize(), can
be set when illegal_highdma() returns true, and we are assured that
illegal_highdma() is invoked prior to skb_needs_linearize() as
skb_needs_linearize() is a static method called only once.
But ~NETIF_F_SG can be set not only there in this same invocation path.
It can also be set when can_checksum_protocol() returns false).

see commit 02932ce9e2c136e6fab2571c8e0dd69ae8ec9853,
Convert skb_need_linearize() to use precomputed features.
Signed-off-by: Rami Rosen <rosenr@marvell.com>
---
 net/core/dev.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3401e2d..a4da9d8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2184,9 +2184,7 @@ EXPORT_SYMBOL(netif_skb_features);
 /*
  * Returns true if either:
  *	1. skb has frag_list and the device doesn't support FRAGLIST, or
- *	2. skb is fragmented and the device does not support SG, or if
- *	   at least one of fragments is in highmem and device does not
- *	   support DMA from it.
+ *	2. skb is fragmented and the device does not support SG.
  */
 static inline int skb_needs_linearize(struct sk_buff *skb,
 				      int features)
-- 
1.7.7.6
