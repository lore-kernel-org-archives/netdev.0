From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc4-netdev1 2/5] r8169: skb alignment nitpicking
Date: Tue, 22 Feb 2005 00:54:50 +0100
Message-ID: <20050221235450.GB31723@electric-eye.fr.zoreil.com>
References: <20050221235125.GD26248@electric-eye.fr.zoreil.com> <20050221235301.GA31723@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jdmason@us.ibm.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050221235301.GA31723@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nail an overrun in skb alignment and remove the relevant magic variable.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-410 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-410	2005-02-17 22:13:04.000000000 +0100
+++ b/drivers/net/r8169.c	2005-02-17 22:17:25.000000000 +0100
@@ -1697,11 +1697,11 @@ static int rtl8169_alloc_rx_skb(struct p
 	dma_addr_t mapping;
 	int ret = 0;
 
-	skb = dev_alloc_skb(rx_buf_sz);
+	skb = dev_alloc_skb(rx_buf_sz + NET_IP_ALIGN);
 	if (!skb)
 		goto err_out;
 
-	skb_reserve(skb, 2);
+	skb_reserve(skb, NET_IP_ALIGN);
 	*sk_buff = skb;
 
 	mapping = pci_map_single(pdev, skb->tail, rx_buf_sz,
@@ -2140,9 +2140,9 @@ static inline int rtl8169_try_rx_copy(st
 	if (pkt_size < rx_copybreak) {
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(pkt_size + 2);
+		skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
 		if (skb) {
-			skb_reserve(skb, 2);
+			skb_reserve(skb, NET_IP_ALIGN);
 			eth_copy_and_sum(skb, sk_buff[0]->tail, pkt_size, 0);
 			*sk_buff = skb;
 			rtl8169_return_to_asic(desc, rx_buf_sz);

_
