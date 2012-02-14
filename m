From: Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/1] usb: cdc-ncm: Increase maximum allowed datagram size
Date: Tue, 14 Feb 2012 14:39:35 +0000
Message-ID: <1329230375-25508-1-git-send-email-toby.gray@realvnc.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
To: Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some NCM devices exist which will send datagrams larger than 2k and
don't support the GetMaxDatagramSize request, such as the Nokia 701
Mobile Telephone.

This sets the maximum limit of datagrams to the theoretical limit for
16-bit NTBs, preventing dropping of large datagrams received from some
devices.

Signed-off-by: Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 3a539a9..d9be846 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -67,8 +67,10 @@
 
 #define	CDC_NCM_MIN_TX_PKT			512	/* bytes */
 
-/* Default value for MaxDatagramSize */
-#define	CDC_NCM_MAX_DATAGRAM_SIZE		2048	/* bytes */
+/* Maximum value for MaxDatagramSize, this is 16k (max NTB size)
+ * minus NTH size (12 bytes) and minus the smallest possible NDP size
+ * (16 bytes). */
+#define	CDC_NCM_MAX_DATAGRAM_SIZE		16356	/* bytes */
 
 /*
  * Maximum amount of datagrams in NCM Datagram Pointer Table, not counting
-- 
1.7.0.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
