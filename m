From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] r8169: Do not increment tx_dropped in TX ring cleaning
Date: Thu, 24 Aug 2017 18:34:43 -0700
Message-ID: <20170825013444.27326-2-f.fainelli@gmail.com>
References: <20170825013444.27326-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, nic_swsd@realtek.com, romieu@fr.zoreil.com,
        edumazet@gmail.com, alexander.h.duyck@intel.com,
        sgruszka@redhat.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33025 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754421AbdHYBex (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 21:34:53 -0400
Received: by mail-qt0-f196.google.com with SMTP id q53so1039887qtq.0
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 18:34:52 -0700 (PDT)
In-Reply-To: <20170825013444.27326-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtl8169_tx_clear_range() is responsible for cleaning up the TX ring
during interface shutdown, incrementing tx_dropped for every SKB that we
left at the time in the ring is misleading.

Fixes: cac4b22f3d6a ("r8169: do not account fragments as packets")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index bd07a15d3b7c..8a1bbd2a6a20 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6863,7 +6863,6 @@ static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start,
 			rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 					     tp->TxDescArray + entry);
 			if (skb) {
-				tp->dev->stats.tx_dropped++;
 				dev_kfree_skb_any(skb);
 				tx_skb->skb = NULL;
 			}
-- 
2.9.3
