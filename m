From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net1080: Neaten netdev_dbg use
Date: Thu, 20 Sep 2012 17:10:23 -0700
Message-ID: <1348186223.2134.1.camel@joe2Laptop>
References: <1348077212.22122.13.camel@joe2Laptop>
	 <20120919193536.GA13933@kroah.com> <20120919194614.GA17585@kroah.com>
	 <20120920.175335.1128494030737237412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120920.175335.1128494030737237412.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unnecessary temporary variable and #ifdef DEBUG block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/net1080.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 29e06e1..c062a3e 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -417,12 +417,9 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	u16			hdr_len, packet_len;
 
 	if (!(skb->len & 0x01)) {
-#ifdef DEBUG
-		struct net_device	*net = dev->net;
 		netdev_dbg(dev->net, "rx framesize %d range %d..%d mtu %d\n",
-			   skb->len, net->hard_header_len, dev->hard_mtu,
-			   net->mtu);
-#endif
+			   skb->len, dev->net->hard_header_len, dev->hard_mtu,
+			   dev->net->mtu);
 		dev->net->stats.rx_frame_errors++;
 		nc_ensure_sync(dev);
 		return 0;
