From: roy.qing.li@gmail.com
Subject: [v2 PATCH] ksz884x: fix Endian
Date: Tue, 10 Jul 2012 14:56:06 +0800
Message-ID: <1341903366-15217-1-git-send-email-roy.qing.li@gmail.com>
Cc: Tristram.Ha@micrel.com, bhutchings@solarflare.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:56242 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570Ab2GJG4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 02:56:18 -0400
Received: by qadb17 with SMTP id b17so2132538qad.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 23:56:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

ETH_P_IP is host Endian, skb->protocol is big Endian, when
compare them, Using htons on skb->protocol is wrong.

And fix two code style issues: indentation and remove
unnecessary parentheses.

CC: Tristram Ha <Tristram.Ha@micrel.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
CC: Joe Perches <joe@perches.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/ethernet/micrel/ksz884x.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index eaf9ff0..0fbe2e2 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4881,8 +4881,8 @@ static netdev_tx_t netdev_tx(struct sk_buff *skb, struct net_device *dev)
 	left = hw_alloc_pkt(hw, skb->len, num);
 	if (left) {
 		if (left < num ||
-				((CHECKSUM_PARTIAL == skb->ip_summed) &&
-				(ETH_P_IPV6 == htons(skb->protocol)))) {
+		    (CHECKSUM_PARTIAL == skb->ip_summed &&
+		     skb->protocol == htons(ETH_P_IPV6))) {
 			struct sk_buff *org_skb = skb;
 
 			skb = netdev_alloc_skb(dev, org_skb->len);
-- 
1.7.1
