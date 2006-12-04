From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/5] r8169: more alignment for the 0x8168
Date: Mon, 4 Dec 2006 01:03:27 +0100
Message-ID: <20061204000327.GE3625@electric-eye.fr.zoreil.com>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, isely@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56027 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1760158AbWLDAEl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 19:04:41 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20061203235257.GA3625@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two thirds of packets are lost because of misalignment. Users of
Asus laptop did apparently not notice it.

Reported on Gigabyte GA-945GM-S2.

Fix for http://bugzilla.kernel.org/show_bug.cgi?id=7517

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0b57050..2379d83 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2018,7 +2018,7 @@ static int rtl8169_alloc_rx_skb(struct p
 	if (!skb)
 		goto err_out;
 
-	skb_reserve(skb, align);
+	skb_reserve(skb, (align - 1) & (u32)skb->data);
 	*sk_buff = skb;
 
 	mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
@@ -2486,7 +2486,7 @@ static inline int rtl8169_try_rx_copy(st
 
 		skb = dev_alloc_skb(pkt_size + align);
 		if (skb) {
-			skb_reserve(skb, align);
+			skb_reserve(skb, (align - 1) & (u32)skb->data);
 			eth_copy_and_sum(skb, sk_buff[0]->data, pkt_size, 0);
 			*sk_buff = skb;
 			rtl8169_mark_to_asic(desc, rx_buf_sz);
-- 
1.4.2.3

