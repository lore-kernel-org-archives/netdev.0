From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 50/75] starfire: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:22 +0100
Message-ID: <1313760467-8598-50-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Ion Badulescu <ionut@badula.org>,
	"David S. Miller" <davem@davemloft.net>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Ben Hutchings <ben@decadent.org.uk>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Ion Badulescu <ionut@badula.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Akinobu Mita <akinobu.mita@gmail.com>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/starfire.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 7ae1f99..d31d52e 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1259,7 +1259,10 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 			skb_frag_t *this_frag = &skb_shinfo(skb)->frags[i - 1];
 			status |= this_frag->size;
 			np->tx_info[entry].mapping =
-				pci_map_single(np->pci_dev, page_address(this_frag->page) + this_frag->page_offset, this_frag->size, PCI_DMA_TODEVICE);
+				pci_map_single(np->pci_dev,
+					       skb_frag_address(this_frag),
+					       this_frag->size,
+					       PCI_DMA_TODEVICE);
 		}
 
 		np->tx_ring[entry].addr = cpu_to_dma(np->tx_info[entry].mapping);
-- 
1.7.2.5
