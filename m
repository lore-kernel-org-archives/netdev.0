From: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Subject: [patch 2/3] hci_usb: remove code obfuscation
Date: Fri, 18 Apr 2008 13:46:53 -0700
Message-ID: <200804182046.m3IKks86014628@imap1.linux-foundation.org>
Cc: hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, pavel-+ZI9xUNit7I@public.gmane.org,
	pavel-AlSwsSmVLrQ@public.gmane.org
To: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>

_urb_free is an alias for kfree... making code longer & harder to
read. Remove it.

Signed-off-by: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Cc: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---

 drivers/bluetooth/hci_usb.c |   10 +++++-----
 drivers/bluetooth/hci_usb.h |    5 -----
 2 files changed, 5 insertions(+), 10 deletions(-)

diff -puN drivers/bluetooth/hci_usb.c~hci_usb-remove-code-obfuscation drivers/bluetooth/hci_usb.c
--- a/drivers/bluetooth/hci_usb.c~hci_usb-remove-code-obfuscation
+++ a/drivers/bluetooth/hci_usb.c
@@ -265,7 +265,7 @@ static int hci_usb_intr_rx_submit(struct
 		BT_ERR("%s intr rx submit failed urb %p err %d",
 				husb->hdev->name, urb, err);
 		_urb_unlink(_urb);
-		_urb_free(_urb);
+		kfree(_urb);
 		kfree(buf);
 	}
 	return err;
@@ -302,7 +302,7 @@ static int hci_usb_bulk_rx_submit(struct
 		BT_ERR("%s bulk rx submit failed urb %p err %d",
 				husb->hdev->name, urb, err);
 		_urb_unlink(_urb);
-		_urb_free(_urb);
+		kfree(_urb);
 		kfree(buf);
 	}
 	return err;
@@ -353,7 +353,7 @@ static int hci_usb_isoc_rx_submit(struct
 		BT_ERR("%s isoc rx submit failed urb %p err %d",
 				husb->hdev->name, urb, err);
 		_urb_unlink(_urb);
-		_urb_free(_urb);
+		kfree(_urb);
 		kfree(buf);
 	}
 	return err;
@@ -431,7 +431,7 @@ static void hci_usb_unlink_urbs(struct h
 					husb->hdev->name, _urb, _urb->type, urb);
 			kfree(urb->setup_packet);
 			kfree(urb->transfer_buffer);
-			_urb_free(_urb);
+			kfree(_urb);
 		}
 	}
 }
@@ -490,7 +490,7 @@ static inline int hci_usb_send_ctrl(stru
 
 		dr = kmalloc(sizeof(*dr), GFP_ATOMIC);
 		if (!dr) {
-			_urb_free(_urb);
+			kfree(_urb);
 			return -ENOMEM;
 		}
 	} else
diff -puN drivers/bluetooth/hci_usb.h~hci_usb-remove-code-obfuscation drivers/bluetooth/hci_usb.h
--- a/drivers/bluetooth/hci_usb.h~hci_usb-remove-code-obfuscation
+++ a/drivers/bluetooth/hci_usb.h
@@ -60,11 +60,6 @@ struct _urb {
 	struct urb        urb;
 };
 
-static inline void _urb_free(struct _urb *_urb)
-{
-	kfree(_urb);
-}
-
 static inline void _urb_queue_init(struct _urb_queue *q)
 {
 	INIT_LIST_HEAD(&q->head);
_
