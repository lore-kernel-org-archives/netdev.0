From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v4 1/2] net: moxa: clear TX descriptor length bits
Date: Tue, 19 Aug 2014 16:49:43 +0200
Message-ID: <1408459784-9385-1-git-send-email-jonas.jensen@gmail.com>
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	bhutchings@solarflare.com, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TX buffer length is not cleared on ndo_start_xmit().
Failing to do so can bug/hang the controller and
cause TX interrupts to stop altogether.

Add TX_DESC1_BUF_SIZE_MASK to bits that are cleared,
before the TX buffer length is set.

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=69031

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Changes since v3:
    
    1. commit message reworded
    
    Applies to next-20140818

 drivers/net/ethernet/moxa/moxart_ether.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 5020fd4..aa45607 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -348,7 +348,8 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	txdes1 = readl(desc + TX_REG_OFFSET_DESC1);
 	txdes1 |= TX_DESC1_LTS | TX_DESC1_FTS;
-	txdes1 &= ~(TX_DESC1_FIFO_COMPLETE | TX_DESC1_INTR_COMPLETE);
+	txdes1 &= ~(TX_DESC1_FIFO_COMPLETE | TX_DESC1_INTR_COMPLETE |
+		    TX_DESC1_BUF_SIZE_MASK);
 	txdes1 |= (len & TX_DESC1_BUF_SIZE_MASK);
 	writel(txdes1, desc + TX_REG_OFFSET_DESC1);
 	writel(TX_DESC0_DMA_OWN, desc + TX_REG_OFFSET_DESC0);
-- 
1.8.2.1
