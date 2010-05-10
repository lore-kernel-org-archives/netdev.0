From: kaber@trash.net
Subject: [PATCH 20/84] netfilter: xtables: limit xt_mac to ethernet devices
Date: Mon, 10 May 2010 22:17:51 +0200
Message-ID: <1273522735-24672-21-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54510 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756710Ab0EJUTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:02 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

I do not see a point of allowing the MAC module to work with devices
that don't possibly have one, e.g. various tunnel interfaces such as
tun and sit.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_mac.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/xt_mac.c b/net/netfilter/xt_mac.c
index 2039d07..b971ce9 100644
--- a/net/netfilter/xt_mac.c
+++ b/net/netfilter/xt_mac.c
@@ -10,6 +10,7 @@
 
 #include <linux/module.h>
 #include <linux/skbuff.h>
+#include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/etherdevice.h>
 
@@ -29,6 +30,8 @@ static bool mac_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	const struct xt_mac_info *info = par->matchinfo;
 	bool ret;
 
+	if (skb->dev == NULL || skb->dev->type != ARPHRD_ETHER)
+		return false;
 	if (skb_mac_header(skb) < skb->head)
 		return false;
 	if (skb_mac_header(skb) + ETH_HLEN > skb->data)
-- 
1.7.0.4

