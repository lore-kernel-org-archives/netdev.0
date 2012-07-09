From: "Andy Cress" <andy.cress@us.kontron.com>
Subject: [PATCH 4/4] pch_gbe: vlan skb len fix
Date: Mon, 9 Jul 2012 06:30:05 -0700
Message-ID: <40680C535D6FE6498883F1640FACD44D010BFC0E@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.kontron.com ([209.118.138.70]:40026 "EHLO
	mail.us.kontron.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753892Ab2GINaG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 09:30:06 -0400
Received: from ka-exchange-1.kontronamerica.local ([10.100.2.39]) by mail.us.kontron.com with ESMTP id JMWXaQdF6MDUDMva for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 06:30:06 -0700 (PDT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Author: Veaceslav Falico <vfalico@redhat.com>
Date:   Tue Apr 10 08:14:17 2012 +0200

    pch_gbe: correctly verify skb->len in vlan case
             to avoid bogus transfer length errors.

Signed-off-by: Andy Cress <andy.cress@us.kontron.com>

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 30ef285..04b0e49 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2158,8 +2158,10 @@ static int pch_gbe_xmit_frame(struct sk_buff
*skb, struct net_device *netdev)
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
 	struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
 	unsigned long flags;
+	int offset;
 
-	if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - 4))) {
+	offset = skb->protocol == htons(ETH_P_8021Q) ? 0 : 4;
+	if (unlikely(skb->len > (adapter->hw.mac.max_frame_size -
offset))) {
 		pr_err("Transfer length Error: skb len: %d > max: %d\n",
 		       skb->len, adapter->hw.mac.max_frame_size);
 		dev_kfree_skb_any(skb);
