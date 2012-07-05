From: roy.qing.li@gmail.com
Subject: [PATCH 2/2] ksz884x: fix Endian
Date: Thu,  5 Jul 2012 10:06:43 +0800
Message-ID: <1341454003-11227-1-git-send-email-roy.qing.li@gmail.com>
Cc: Tristram.Ha@micrel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46538 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab2GECGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 22:06:55 -0400
Received: by bkwj10 with SMTP id j10so3022655bkw.19
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2012 19:06:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

ETH_P_IP is host Endian, skb->protocol is big Endian, when
compare them, we should change skb->protocol from big endian
to host endian, ntohs, not htons.

CC: Tristram Ha <Tristram.Ha@micrel.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/ethernet/micrel/ksz884x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index eaf9ff0..d9727f7 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4882,7 +4882,7 @@ static netdev_tx_t netdev_tx(struct sk_buff *skb, struct net_device *dev)
 	if (left) {
 		if (left < num ||
 				((CHECKSUM_PARTIAL == skb->ip_summed) &&
-				(ETH_P_IPV6 == htons(skb->protocol)))) {
+				(ETH_P_IPV6 == ntohs(skb->protocol)))) {
 			struct sk_buff *org_skb = skb;
 
 			skb = netdev_alloc_skb(dev, org_skb->len);
-- 
1.7.1
