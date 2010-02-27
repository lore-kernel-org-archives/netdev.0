From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 3/9] Bluetooth: Add missing kfree() on error path in Atheros driver
Date: Sat, 27 Feb 2010 23:38:32 +0100
Message-ID: <10f7891f998e84acfa31ac9c5a0fea052c39ecb8.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
 <8e5b2308489dbca27c104fc6a557d4c9348552e5.1267276098.git.marcel@holtmann.org>
 <8978111e2d148f75bd5e329a14600feadc567381.1267276098.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54692 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936360Ab0B0WkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 17:40:19 -0500
In-Reply-To: <8978111e2d148f75bd5e329a14600feadc567381.1267276098.git.marcel@holtmann.org>
In-Reply-To: <cover.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>

Add a couple kfree() calls on an error path.

Signed-off-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/ath3k.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index add9485..128cae4 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -143,6 +143,8 @@ static int ath3k_probe(struct usb_interface *intf,
 	usb_set_intfdata(intf, data);
 	if (ath3k_load_firmware(data, data->fw_data, data->fw_size)) {
 		usb_set_intfdata(intf, NULL);
+		kfree(data->fw_data);
+		kfree(data);
 		return -EIO;
 	}
 
-- 
1.6.6

