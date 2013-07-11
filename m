From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 16/50] USB: serial: quatech2: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:39 +0800
Message-ID: <1373533573-12272-17-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Johan Hovold <jhovold@gmail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:49564 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090Ab3GKJIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:08:46 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Johan Hovold <jhovold@gmail.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/serial/quatech2.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/serial/quatech2.c b/drivers/usb/serial/quatech2.c
index d997432..95e5dbf 100644
--- a/drivers/usb/serial/quatech2.c
+++ b/drivers/usb/serial/quatech2.c
@@ -630,16 +630,17 @@ static void qt2_write_bulk_callback(struct urb *urb)
 {
 	struct usb_serial_port *port;
 	struct qt2_port_private *port_priv;
+	unsigned long flags;
 
 	port = urb->context;
 	port_priv = usb_get_serial_port_data(port);
 
-	spin_lock(&port_priv->urb_lock);
+	spin_lock_irqsave(&port_priv->urb_lock, flags);
 
 	port_priv->urb_in_use = false;
 	usb_serial_port_softint(port);
 
-	spin_unlock(&port_priv->urb_lock);
+	spin_unlock_irqrestore(&port_priv->urb_lock, flags);
 
 }
 
-- 
1.7.9.5
