From: Ben Greear <greearb@candelatech.com>
Subject: [net 1/2] net:  dev_forward_skb should call nf_reset
Date: Thu, 22 Jul 2010 12:54:47 -0700
Message-ID: <1279828488-17800-2-git-send-email-greearb@candelatech.com>
References: <1279828488-17800-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54549 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933Ab0GVTyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 15:54:52 -0400
In-Reply-To: <1279828488-17800-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With conn-track zones and probably with different network
namespaces, the netfilter logic needs to be re-calculated
on packet receive.  If the netfilter logic is not reset,
it will not be recalculated properly.  This patch adds
the nf_reset logic to dev_forward_skb.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 7ac33e5... 22eee4e... M	net/core/dev.c
 net/core/dev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7ac33e5..22eee4e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1482,6 +1482,7 @@ static inline void net_timestamp(struct sk_buff *skb)
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 {
 	skb_orphan(skb);
+	nf_reset(skb);
 
 	if (!(dev->flags & IFF_UP) ||
 	    (skb->len > (dev->mtu + dev->hard_header_len))) {
-- 
1.6.2.5

