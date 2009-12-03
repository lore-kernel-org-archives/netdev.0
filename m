From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 04/18] Bluetooth: Fix miscdev ops owner for virtual driver
Date: Thu,  3 Dec 2009 19:45:41 +0100
Message-ID: <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
 <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37648 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755555AbZLCSp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:45:56 -0500
In-Reply-To: <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The /dev/vhci ops don't refer to the module and so it is possible to
unload the module while the file descriptor is in use. This was an
accidental removal after the cleanup.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/hci_vhci.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/bluetooth/hci_vhci.c b/drivers/bluetooth/hci_vhci.c
index c1d389f..7595274 100644
--- a/drivers/bluetooth/hci_vhci.c
+++ b/drivers/bluetooth/hci_vhci.c
@@ -276,6 +276,7 @@ static int vhci_release(struct inode *inode, struct file *file)
 }
 
 static const struct file_operations vhci_fops = {
+	.owner		= THIS_MODULE,
 	.read		= vhci_read,
 	.write		= vhci_write,
 	.poll		= vhci_poll,
-- 
1.6.5.2

