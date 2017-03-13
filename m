From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 1/2] wireless: ath9k_htc: fix NULL-deref at probe
Date: Mon, 13 Mar 2017 13:44:20 +0100
Message-ID: <20170313124421.28587-1-johan@kernel.org>
Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Daniel Drake <dsd@gentoo.org>,
        Ulrich Kunitz <kune@deine-taler.de>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>,
        Sujith Manoharan <Sujith.Manoharan@atheros.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to check the number of endpoints to avoid dereferencing a
NULL-pointer or accessing memory beyond the endpoint array should a
malicious device lack the expected endpoints.

Fixes: 36bcce430657 ("ath9k_htc: Handle storage devices")
Cc: Sujith Manoharan <Sujith.Manoharan@atheros.com>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/wireless/ath/ath9k/hif_usb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index de2d212f39ec..9206955e865a 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -1219,6 +1219,9 @@ static int send_eject_command(struct usb_interface *interface)
 	u8 bulk_out_ep;
 	int r;
 
+	if (iface_desc->desc.bNumEndpoints < 2)
+		return -ENODEV;
+
 	/* Find bulk out endpoint */
 	for (r = 1; r >= 0; r--) {
 		endpoint = &iface_desc->endpoint[r].desc;
-- 
2.12.0
