From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 21/25] net: pxa168_eth: Use kcalloc() in two functions
Date: Mon, 17 Apr 2017 17:31:08 +0200
Message-ID: <5afe517a-ac25-dae2-55b9-71bef428a389@users.sourceforge.net>
References: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Mirko Lindner <mlindner@marvell.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:57107 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754636AbdDQPbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 11:31:25 -0400
In-Reply-To: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 17 Apr 2017 14:32:14 +0200

Multiplications for the size determination of memory allocations
indicated that array data structures should be processed.
Thus use the corresponding function "kcalloc".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 28cb36d9e50a..2404eac51c63 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1036,8 +1036,7 @@ static int rxq_init(struct net_device *dev)
 	int rx_desc_num = pep->rx_ring_size;
 
 	/* Allocate RX skb rings */
-	pep->rx_skb = kzalloc(sizeof(*pep->rx_skb) * pep->rx_ring_size,
-			     GFP_KERNEL);
+	pep->rx_skb = kcalloc(rx_desc_num, sizeof(*pep->rx_skb), GFP_KERNEL);
 	if (!pep->rx_skb)
 		return -ENOMEM;
 
@@ -1096,8 +1095,7 @@ static int txq_init(struct net_device *dev)
 	int size = 0, i = 0;
 	int tx_desc_num = pep->tx_ring_size;
 
-	pep->tx_skb = kzalloc(sizeof(*pep->tx_skb) * pep->tx_ring_size,
-			     GFP_KERNEL);
+	pep->tx_skb = kcalloc(tx_desc_num, sizeof(*pep->tx_skb), GFP_KERNEL);
 	if (!pep->tx_skb)
 		return -ENOMEM;
 
-- 
2.12.2
