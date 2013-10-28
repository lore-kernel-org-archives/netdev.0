From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 2/5] net/usb/r8152: make sure the tx checksum setting is correct
Date: Mon, 28 Oct 2013 19:58:11 +0800
Message-ID: <1382961494-2272-3-git-send-email-hayeswang@realtek.com>
References: <1382961494-2272-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382961494-2272-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clear the checksum setting before checking the necessary of hardware
checksum.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 5dbfe50..815d890 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1094,6 +1094,7 @@ r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc, struct sk_buff *skb)
 	memset(desc, 0, sizeof(*desc));
 
 	desc->opts1 = cpu_to_le32((skb->len & TX_LEN_MASK) | TX_FS | TX_LS);
+	desc->opts2 = 0;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		__be16 protocol;
-- 
1.8.3.1
