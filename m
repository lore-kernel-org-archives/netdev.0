From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 5/5] Bluetooth: Prevent ill-timed autosuspend in USB driver
Date: Thu, 17 Dec 2009 12:22:47 -0800
Message-ID: <652fd781a52ad6e24b908cd8b83d12699754f253.1261080894.git.marcel@holtmann.org>
References: <cover.1261080894.git.marcel@holtmann.org>
 <971beb83aeb2a309175682cf5683d64fd4591841.1261080894.git.marcel@holtmann.org>
 <186de9a33803c7ee20d9af75c9049b50e68a3a08.1261080894.git.marcel@holtmann.org>
 <186ee8cf0130993dea8ab8867ff1af8a148f9ae6.1261080894.git.marcel@holtmann.org>
 <b13f5860447a98daf0358a51fbff66154ac0663a.1261080894.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33954 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765347AbZLQUXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 15:23:24 -0500
In-Reply-To: <b13f5860447a98daf0358a51fbff66154ac0663a.1261080894.git.marcel@holtmann.org>
In-Reply-To: <cover.1261080894.git.marcel@holtmann.org>
References: <cover.1261080894.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>

The device must be marked busy as it receives data.

Signed-off-by: Oliver Neukum <oliver@neukum.org>
Tested-by: Matthew Garrett <mjg@redhat.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btusb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 4d29059..a699f09 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -307,6 +307,7 @@ static void btusb_bulk_complete(struct urb *urb)
 		return;
 
 	usb_anchor_urb(urb, &data->bulk_anchor);
+	usb_mark_last_busy(data->udev);
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
-- 
1.6.5.2

