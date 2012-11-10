From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: [PATCH] r8169: Drop tp arg from rtl8169_tx_vlan_tag()
Date: Sat, 10 Nov 2012 21:11:02 +0400
Message-ID: <1352567462-23174-1-git-send-email-kirr@mns.spb.ru>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org, Kirill Smelkov <kirr@mns.spb.ru>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:34010 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752100Ab2KJRKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Nov 2012 12:10:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since eab6d18d (vlan: Don't check for vlan group before
vlan_tx_tag_present.) we don't check tp->vlgrp and thus tp is not needed
in this function.

Signed-off-by: Kirill Smelkov <kirr@mns.spb.ru>
---
 drivers/net/ethernet/realtek/r8169.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index d6c6cfb..3b924d2 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1819,8 +1819,7 @@ static int rtl8169_set_features(struct net_device *dev,
 }
 
 
-static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
-				      struct sk_buff *skb)
+static inline u32 rtl8169_tx_vlan_tag(struct sk_buff *skb)
 {
 	return (vlan_tx_tag_present(skb)) ?
 		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
@@ -5816,7 +5815,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	tp->tx_skb[entry].len = len;
 	txd->addr = cpu_to_le64(mapping);
 
-	opts[1] = cpu_to_le32(rtl8169_tx_vlan_tag(tp, skb));
+	opts[1] = cpu_to_le32(rtl8169_tx_vlan_tag(skb));
 	opts[0] = DescOwn;
 
 	rtl8169_tso_csum(tp, skb, opts);
-- 
1.8.0.267.g7a4c58c
