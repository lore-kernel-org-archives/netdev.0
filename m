From: Peter Korsgaard <peter@korsgaard.com>
Subject: [PATCH 2/4] dm9601: fix reception of full size ethernet frames on dm9620/dm9621a
Date: Mon, 16 Dec 2013 11:35:33 +0100
Message-ID: <1387190135-17052-3-git-send-email-peter@korsgaard.com>
References: <1387190135-17052-1-git-send-email-peter@korsgaard.com>
Cc: joseph_chang@davicom.com.tw, Peter Korsgaard <peter@korsgaard.com>,
	<stable@vger.kernel.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1387190135-17052-1-git-send-email-peter@korsgaard.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dm9620/dm9621a require room for 4 byte padding even in dm9601 (3 byte
header) mode.

Cc: <stable@vger.kernel.org>
Signed-off-by: Peter Korsgaard <peter@korsgaard.com>
---
 drivers/net/usb/dm9601.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 8e88572..aca0285 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -364,7 +364,12 @@ static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->ethtool_ops = &dm9601_ethtool_ops;
 	dev->net->hard_header_len += DM_TX_OVERHEAD;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
-	dev->rx_urb_size = dev->net->mtu + ETH_HLEN + DM_RX_OVERHEAD;
+
+	/* dm9620/21a require room for 4 byte padding, even in dm9601
+	 * mode, so we need +1 to be able to receive full size
+	 * ethernet frames.
+	 */
+	dev->rx_urb_size = dev->net->mtu + ETH_HLEN + DM_RX_OVERHEAD + 1;
 
 	dev->mii.dev = dev->net;
 	dev->mii.mdio_read = dm9601_mdio_read;
-- 
1.8.5.1
