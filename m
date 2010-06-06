From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH] asix: check packet size against mtu+ETH_HLEN instead of
	ETH_FRAME_LEN
Date: Mon, 07 Jun 2010 02:35:31 +0300
Message-ID: <20100606233531.23585.10292.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Hollis <dhollis@davehollis.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sinikuusama.dnainternet.net ([83.102.40.134]:49995 "EHLO
	sinikuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752432Ab0FFXpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jun 2010 19:45:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver checks received packet is too large in asix_rx_fixup() and fails if it is. Problem is
that MTU might be set larger than 1500 and asix fails to work correctly with VLAN tagged
packets. The check should be 'dev->net->mtu + ETH_HLEN' instead.

Tested with AX88772.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---
 drivers/net/usb/asix.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 7e797ed..aea4645 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -344,7 +344,7 @@ static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			return 2;
 		}
 
-		if (size > ETH_FRAME_LEN) {
+		if (size > dev->net->mtu + ETH_HLEN) {
 			netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
 				   size);
 			return 0;

