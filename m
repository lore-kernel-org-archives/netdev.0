From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH v2 06/11] hso: rename hso_dev into serial in hso_free_interface()
Date: Fri, 30 Jan 2015 13:21:58 +0100
Message-ID: <1422620523-15021-7-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-2-git-send-email-olivier@sobrie.be>
 <1422620523-15021-3-git-send-email-olivier@sobrie.be>
 <1422620523-15021-4-git-send-email-olivier@sobrie.be>
 <1422620523-15021-5-git-send-email-olivier@sobrie.be>
 <1422620523-15021-6-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>, Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422620523-15021-6-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In other functions of the driver, variables of type "struct hso_serial"
are denoted by "serial" and variables of type "struct hso_device" are
denoted by "hso_dev". This patch makes the hso_free_interface()
consistent with these notations.

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
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
