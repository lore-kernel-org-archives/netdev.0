From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 03/21] r8169: kill eth_copy_and_sum()
Date: Fri, 29 Jun 2007 22:17:52 +0200
Message-ID: <20070629201752.GE3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41519 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753294AbXF2UVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:21:39 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It hasn't "summed" anything in over 7 years, and it's
just a straight mempcy ala skb_copy_to_linear_data()
so just get rid of it.

Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 1f7fb54..e4827a4 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2495,7 +2495,7 @@ static inline int rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
 		skb = dev_alloc_skb(pkt_size + align);
 		if (skb) {
 			skb_reserve(skb, (align - 1) & (unsigned long)skb->data);
-			eth_copy_and_sum(skb, sk_buff[0]->data, pkt_size, 0);
+			skb_copy_from_linear_data(*sk_buff, skb->data, pkt_size);
 			*sk_buff = skb;
 			rtl8169_mark_to_asic(desc, rx_buf_sz);
 			ret = 0;
-- 
1.4.4.2

