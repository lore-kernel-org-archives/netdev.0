From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Make xircom cardbus handle shared irq
Date: Thu, 22 Jan 2004 16:49:20 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040122164920.5c32a649.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Current driver doesn't do shared irq properly.  When testing on
a laptop here irq 3 get shared between pcmcia slot and tty/IRDA

diff -Nru a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
--- a/drivers/net/tulip/xircom_cb.c	Thu Jan 22 16:46:34 2004
+++ b/drivers/net/tulip/xircom_cb.c	Thu Jan 22 16:46:34 2004
@@ -342,6 +342,11 @@
 	printk("tx status 0x%08x 0x%08x \n",card->tx_buffer[0],card->tx_buffer[4]);
 	printk("rx status 0x%08x 0x%08x \n",card->rx_buffer[0],card->rx_buffer[4]);
 #endif	
+	/* Handle shared irq and hotplug */
+	if (status == 0 || status == 0xffffffff) {
+		spin_unlock(&card->lock);
+		return IRQ_NONE;
+	}
 
 	if (link_status_changed(card)) {
 		int newlink;
