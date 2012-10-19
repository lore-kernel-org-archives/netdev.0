From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 11/21] usb: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
Date: Thu, 18 Oct 2012 21:14:55 -0700
Message-ID: <31a2e37a4c24da868af415922eac017902cca583.1350618011.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the old ether_addr tests to eth_addr_<foo>.
Adds api consistency.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/usb/gadget/u_ether.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index 6458764..d6a5577 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -510,13 +510,13 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
 	if (!is_promisc(cdc_filter)) {
 		u8		*dest = skb->data;
 
-		if (is_multicast_ether_addr(dest)) {
+		if (eth_addr_multicast(dest)) {
 			u16	type;
 
 			/* ignores USB_CDC_PACKET_TYPE_MULTICAST and host
 			 * SET_ETHERNET_MULTICAST_FILTERS requests
 			 */
-			if (is_broadcast_ether_addr(dest))
+			if (eth_addr_broadcast(dest))
 				type = USB_CDC_PACKET_TYPE_BROADCAST;
 			else
 				type = USB_CDC_PACKET_TYPE_ALL_MULTICAST;
@@ -721,7 +721,7 @@ static int get_ether_addr(const char *str, u8 *dev_addr)
 			num |= hex_to_bin(*str++);
 			dev_addr [i] = num;
 		}
-		if (is_valid_ether_addr(dev_addr))
+		if (eth_addr_valid(dev_addr))
 			return 0;
 	}
 	eth_random_addr(dev_addr);
-- 
1.7.8.111.gad25c.dirty
