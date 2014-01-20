From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/7] caif_usb: Use ether_addr_copy
Date: Mon, 20 Jan 2014 09:52:17 -0800
Message-ID: <73ad3aea35df9926aa882b2b863d54c2c01e401d.1390239869.git.joe@perches.com>
References: <cover.1390239869.git.joe@perches.com>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1390239869.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use ether_addr_copy instead of memcpy(a, b, ETH_ALEN) to
save some cycles on arm and powerpc.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/caif/caif_usb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
index 75ed04b..dda589c 100644
--- a/net/caif/caif_usb.c
+++ b/net/caif/caif_usb.c
@@ -105,8 +105,8 @@ static struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
 	 *	5-11	source address
 	 *	12-13	protocol type
 	 */
-	memcpy(&this->tx_eth_hdr[ETH_ALEN], braddr, ETH_ALEN);
-	memcpy(&this->tx_eth_hdr[ETH_ALEN], ethaddr, ETH_ALEN);
+	ether_addr_copy(&this->tx_eth_hdr[ETH_ALEN], braddr);
+	ether_addr_copy(&this->tx_eth_hdr[ETH_ALEN], ethaddr);
 	this->tx_eth_hdr[12] = cpu_to_be16(ETH_P_802_EX1) & 0xff;
 	this->tx_eth_hdr[13] = (cpu_to_be16(ETH_P_802_EX1) >> 8) & 0xff;
 	pr_debug("caif ethernet TX-header dst:%pM src:%pM type:%02x%02x\n",
-- 
1.8.1.2.459.gbcd45b4.dirty
