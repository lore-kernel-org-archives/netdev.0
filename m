From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH 03/11] hso: fix memory leak when device disconnects
Date: Tue, 20 Jan 2015 13:29:30 +0100
Message-ID: <1421756978-4093-4-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1421756978-4093-2-git-send-email-olivier@sobrie.be>
 <1421756978-4093-3-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421756978-4093-3-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the disconnect path, tx_buffer should freed like tx_data to avoid
a memory leak when the device disconnects.

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/usb/hso.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 3a6c630..470ef9e 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2253,6 +2253,7 @@ static void hso_serial_common_free(struct hso_serial *serial)
 
 	/* unlink and free TX URB */
 	usb_free_urb(serial->tx_urb);
+	kfree(serial->tx_buffer);
 	kfree(serial->tx_data);
 	tty_port_destroy(&serial->port);
 }
-- 
2.2.0
