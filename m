From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 2/2] wireless: zd1211rw: fix NULL-deref at probe
Date: Mon, 13 Mar 2017 13:44:21 +0100
Message-ID: <20170313124421.28587-2-johan@kernel.org>
References: <20170313124421.28587-1-johan@kernel.org>
Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Daniel Drake <dsd@gentoo.org>,
        Ulrich Kunitz <kune@deine-taler.de>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35353 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdCMMot (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 08:44:49 -0400
In-Reply-To: <20170313124421.28587-1-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure to check the number of endpoints to avoid dereferencing a
NULL-pointer or accessing memory beyond the endpoint array should a
malicious device lack the expected endpoints.

Fixes: a1030e92c150 ("[PATCH] zd1211rw: Convert installer CDROM device
into WLAN device")
Cc: Daniel Drake <dsd@gentoo.org>

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/wireless/zydas/zd1211rw/zd_usb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/wireless/zydas/zd1211rw/zd_usb.c b/drivers/net/wireless/zydas/zd1211rw/zd_usb.c
index c5effd6c6be9..01ca1d57b3d9 100644
--- a/drivers/net/wireless/zydas/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zydas/zd1211rw/zd_usb.c
@@ -1278,6 +1278,9 @@ static int eject_installer(struct usb_interface *intf)
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
