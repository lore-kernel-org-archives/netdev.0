From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH v2 10/11] hso: add missing cancel_work_sync in disconnect()
Date: Fri, 30 Jan 2015 13:22:02 +0100
Message-ID: <1422620523-15021-11-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-2-git-send-email-olivier@sobrie.be>
 <1422620523-15021-3-git-send-email-olivier@sobrie.be>
 <1422620523-15021-4-git-send-email-olivier@sobrie.be>
 <1422620523-15021-5-git-send-email-olivier@sobrie.be>
 <1422620523-15021-6-git-send-email-olivier@sobrie.be>
 <1422620523-15021-7-git-send-email-olivier@sobrie.be>
 <1422620523-15021-8-git-send-email-olivier@sobrie.be>
 <1422620523-15021-9-git-send-email-olivier@sobrie.be>
 <1422620523-15021-10-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>, Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422620523-15021-10-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For hso serial devices, two cancel_work_sync were missing in the
disconnect method.

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/usb/hso.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index c916ab5..c14fc80 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -3107,6 +3107,8 @@ static void hso_free_interface(struct usb_interface *interface)
 			mutex_lock(&serial->parent->mutex);
 			serial->parent->usb_gone = 1;
 			mutex_unlock(&serial->parent->mutex);
+			cancel_work_sync(&serial_table[i]->async_put_intf);
+			cancel_work_sync(&serial_table[i]->async_get_intf);
 			hso_serial_tty_unregister(serial);
 			kref_put(&serial_table[i]->ref, hso_serial_ref_free);
 			set_serial_by_index(i, NULL);
-- 
2.2.0
