From: Alan Ott <alan@signal11.us>
Subject: [PATCH] 6lowpan: consider checksum bytes in fragmentation threshold
Date: Thu, 29 Nov 2012 20:55:44 -0500
Message-ID: <1354240544-22214-1-git-send-email-alan@signal11.us>
References: <504EA95C.9010003@signal11.us>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alan Ott <alan@signal11.us>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <504EA95C.9010003@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the threshold for framentation of a lowpan packet from
using the MTU size to now use the MTU size minus the checksum length,
which is added by the hardware. For IEEE 802.15.4, this effectively
changes it from 127 bytes to 125 bytes.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 net/ieee802154/6lowpan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 6d42c17..f651da6 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1047,7 +1047,8 @@ static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto error;
 	}
 
-	if (skb->len <= IEEE802154_MTU) {
+	/* Send directly if less than the MTU minus the 2 checksum bytes. */
+	if (skb->len <= IEEE802154_MTU - IEEE802154_MFR_SIZE) {
 		err = dev_queue_xmit(skb);
 		goto out;
 	}
-- 
1.7.11.2
