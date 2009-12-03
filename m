From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 02/18] Bluetooth: Remove stub ioctl in hci_vhci
Date: Thu,  3 Dec 2009 19:45:39 +0100
Message-ID: <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37645 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756393AbZLCSpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:45:55 -0500
In-Reply-To: <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>

Remove the empty ioctl which just returns -EINVAL. vfs_ioctl() will
return -ENOTTY instead, but I doubt that any application will notice
the difference :)

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/hci_vhci.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/bluetooth/hci_vhci.c b/drivers/bluetooth/hci_vhci.c
index d5cde6d..ff02e90 100644
--- a/drivers/bluetooth/hci_vhci.c
+++ b/drivers/bluetooth/hci_vhci.c
@@ -218,12 +218,6 @@ static unsigned int vhci_poll(struct file *file, poll_table *wait)
 	return POLLOUT | POLLWRNORM;
 }
 
-static int vhci_ioctl(struct inode *inode, struct file *file,
-					unsigned int cmd, unsigned long arg)
-{
-	return -EINVAL;
-}
-
 static int vhci_open(struct inode *inode, struct file *file)
 {
 	struct vhci_data *data;
@@ -287,7 +281,6 @@ static const struct file_operations vhci_fops = {
 	.read		= vhci_read,
 	.write		= vhci_write,
 	.poll		= vhci_poll,
-	.ioctl		= vhci_ioctl,
 	.open		= vhci_open,
 	.release	= vhci_release,
 };
-- 
1.6.5.2

