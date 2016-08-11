From: Wolfram Sang <wsa-dev@sang-engineering.com>
Subject: [PATCH 15/16] net: wireless: marvell: mwifiex: usb: don't print error when allocating urb fails
Date: Thu, 11 Aug 2016 23:13:07 +0200
Message-ID: <1470949988-25705-3-git-send-email-wsa-dev@sang-engineering.com>
References: <1470949539-25392-1-git-send-email-wsa-dev@sang-engineering.com>
 <1470949988-25705-1-git-send-email-wsa-dev@sang-engineering.com>
Cc: Wolfram Sang <wsa-dev@sang-engineering.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.zeus03.de ([194.117.254.33]:56572 "EHLO mail.zeus03.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932748AbcHKVNh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2016 17:13:37 -0400
In-Reply-To: <1470949988-25705-1-git-send-email-wsa-dev@sang-engineering.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kmalloc will print enough information in case of failure.

Signed-off-by: Wolfram Sang <wsa-dev@sang-engineering.com>
---
 drivers/net/wireless/marvell/mwifiex/usb.c | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/usb.c b/drivers/net/wireless/marvell/mwifiex/usb.c
index 0857575c5c39fe..3bd04f52f36988 100644
--- a/drivers/net/wireless/marvell/mwifiex/usb.c
+++ b/drivers/net/wireless/marvell/mwifiex/usb.c
@@ -657,11 +657,8 @@ static int mwifiex_usb_tx_init(struct mwifiex_adapter *adapter)
 	card->tx_cmd.ep = card->tx_cmd_ep;
 
 	card->tx_cmd.urb = usb_alloc_urb(0, GFP_KERNEL);
-	if (!card->tx_cmd.urb) {
-		mwifiex_dbg(adapter, ERROR,
-			    "tx_cmd.urb allocation failed\n");
+	if (!card->tx_cmd.urb)
 		return -ENOMEM;
-	}
 
 	for (i = 0; i < MWIFIEX_TX_DATA_PORT; i++) {
 		port = &card->port[i];
@@ -677,11 +674,8 @@ static int mwifiex_usb_tx_init(struct mwifiex_adapter *adapter)
 			port->tx_data_list[j].ep = port->tx_data_ep;
 			port->tx_data_list[j].urb =
 					usb_alloc_urb(0, GFP_KERNEL);
-			if (!port->tx_data_list[j].urb) {
-				mwifiex_dbg(adapter, ERROR,
-					    "urb allocation failed\n");
+			if (!port->tx_data_list[j].urb)
 				return -ENOMEM;
-			}
 		}
 	}
 
@@ -697,10 +691,8 @@ static int mwifiex_usb_rx_init(struct mwifiex_adapter *adapter)
 	card->rx_cmd.ep = card->rx_cmd_ep;
 
 	card->rx_cmd.urb = usb_alloc_urb(0, GFP_KERNEL);
-	if (!card->rx_cmd.urb) {
-		mwifiex_dbg(adapter, ERROR, "rx_cmd.urb allocation failed\n");
+	if (!card->rx_cmd.urb)
 		return -ENOMEM;
-	}
 
 	card->rx_cmd.skb = dev_alloc_skb(MWIFIEX_RX_CMD_BUF_SIZE);
 	if (!card->rx_cmd.skb)
@@ -714,11 +706,8 @@ static int mwifiex_usb_rx_init(struct mwifiex_adapter *adapter)
 		card->rx_data_list[i].ep = card->rx_data_ep;
 
 		card->rx_data_list[i].urb = usb_alloc_urb(0, GFP_KERNEL);
-		if (!card->rx_data_list[i].urb) {
-			mwifiex_dbg(adapter, ERROR,
-				    "rx_data_list[] urb allocation failed\n");
+		if (!card->rx_data_list[i].urb)
 			return -1;
-		}
 		if (mwifiex_usb_submit_rx_urb(&card->rx_data_list[i],
 					      MWIFIEX_RX_DATA_BUF_SIZE))
 			return -1;
-- 
2.8.1
