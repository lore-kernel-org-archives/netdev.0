From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH RFC] 1/2 cdc_ncm: export cdc_ncm_align_tail
Date: Tue, 23 Jun 2015 00:32:14 +0200
Message-ID: <1435012335-6055-2-git-send-email-mrkiko.rs@gmail.com>
References: <1435012335-6055-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Oliver Neukum <oneukum@suse.com>,
	Enrico Mioso <mrkiko.rs@gmail.com>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35393 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbbFVWdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 18:33:16 -0400
In-Reply-To: <1435012335-6055-1-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export this function to allow for reusing it in other drivers needing NCM
frames alignment, such as the huawei_cdc_ncm one.

Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
---
 drivers/net/usb/cdc_ncm.c   | 3 ++-
 include/linux/usb/cdc_ncm.h | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 8067b8f..1a8b619 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -967,7 +967,7 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
 	return ret;
 }
 
-static void cdc_ncm_align_tail(struct sk_buff *skb, size_t modulus, size_t remainder, size_t max)
+void cdc_ncm_align_tail(struct sk_buff *skb, size_t modulus, size_t remainder, size_t max)
 {
 	size_t align = ALIGN(skb->len, modulus) - skb->len + remainder;
 
@@ -976,6 +976,7 @@ static void cdc_ncm_align_tail(struct sk_buff *skb, size_t modulus, size_t remai
 	if (align && skb_tailroom(skb) >= align)
 		memset(skb_put(skb, align), 0, align);
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_align_tail);
 
 /* return a pointer to a valid struct usb_cdc_ncm_ndp16 of type sign, possibly
  * allocating a new one within skb
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 7c9b484..8fe7ef0 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -141,5 +141,6 @@ int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffset);
 struct sk_buff *
 cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags);
 int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in);
+void cdc_ncm_align_tail(struct sk_buff *skb, size_t modulus, size_t remainder, size_t max);
 
 #endif /* __LINUX_USB_CDC_NCM_H */
-- 
2.4.4
