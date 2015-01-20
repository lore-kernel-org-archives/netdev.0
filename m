From: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 06/11] hso: rename hso_dev into serial in hso_free_interface()
Date: Tue, 20 Jan 2015 13:29:33 +0100
Message-ID: <1421756978-4093-7-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1421756978-4093-2-git-send-email-olivier@sobrie.be>
 <1421756978-4093-3-git-send-email-olivier@sobrie.be>
 <1421756978-4093-4-git-send-email-olivier@sobrie.be>
 <1421756978-4093-5-git-send-email-olivier@sobrie.be>
 <1421756978-4093-6-git-send-email-olivier@sobrie.be>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
To: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421756978-4093-6-git-send-email-olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In other functions of the driver, variables of type "struct hso_serial"
are denoted by "serial" and variables of type "struct hso_device" are
denoted by "hso_dev". This patch makes the hso_free_interface()
consistent with these notations.

Signed-off-by: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
---
 drivers/net/usb/hso.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 2f2343d..484e423 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -3115,17 +3115,17 @@ static void hso_serial_ref_free(struct kref *ref)
 
 static void hso_free_interface(struct usb_interface *interface)
 {
-	struct hso_serial *hso_dev;
+	struct hso_serial *serial;
 	int i;
 
 	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
 		if (serial_table[i] &&
 		    (serial_table[i]->interface == interface)) {
-			hso_dev = dev2ser(serial_table[i]);
-			tty_port_tty_hangup(&hso_dev->port, false);
-			mutex_lock(&hso_dev->parent->mutex);
-			hso_dev->parent->usb_gone = 1;
-			mutex_unlock(&hso_dev->parent->mutex);
+			serial = dev2ser(serial_table[i]);
+			tty_port_tty_hangup(&serial->port, false);
+			mutex_lock(&serial->parent->mutex);
+			serial->parent->usb_gone = 1;
+			mutex_unlock(&serial->parent->mutex);
 			kref_put(&serial_table[i]->ref, hso_serial_ref_free);
 		}
 	}
-- 
2.2.0

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
