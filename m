From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] usb/kaweth: use GFP_ATOMIC under spin_lock in usb_start_wait_urb()
Date: Sat, 10 Jan 2015 02:16:22 +0300
Message-ID: <1420845382-25815-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit e4c7f259c5be ("USB: kaweth.c: use GFP_ATOMIC under spin_lock")
makes sure that kaweth_internal_control_msg() allocates memory with GFP_ATOMIC,
but kaweth_internal_control_msg() also calls usb_start_wait_urb()
that still allocates memory with GFP_NOIO.

The patch fixes usb_start_wait_urb() as well.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/usb/kaweth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index dcb6d33141e0..1e9cdca37014 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -1276,7 +1276,7 @@ static int usb_start_wait_urb(struct urb *urb, int timeout, int* actual_length)
         awd.done = 0;
 
         urb->context = &awd;
-        status = usb_submit_urb(urb, GFP_NOIO);
+        status = usb_submit_urb(urb, GFP_ATOMIC);
         if (status) {
                 // something went wrong
                 usb_free_urb(urb);
-- 
1.9.1
