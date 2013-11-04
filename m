From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next v6 1/3] net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions for re-use
Date: Mon,  4 Nov 2013 09:50:47 +0100
Message-ID: <1383555049-24834-2-git-send-email-bjorn@mork.no>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48274 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709Ab3KDIvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 03:51:08 -0500
In-Reply-To: <1383555049-24834-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Enrico Mioso <mrkiko.rs@gmail.com>

Some drivers implementing NCM-like protocols, may re-use those function=
s, as is
the case in the huawei_cdc_ncm driver.
Export them via EXPORT_SYMBOL_GPL, in accordance with how other functio=
ns have
been exported.

Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c   |    6 ++++--
 include/linux/usb/cdc_ncm.h |    3 +++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 11c7033..1763195 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -830,7 +830,7 @@ static void cdc_ncm_txpath_bh(unsigned long param)
 	}
 }
=20
-static struct sk_buff *
+struct sk_buff *
 cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 {
 	struct sk_buff *skb_out;
@@ -857,6 +857,7 @@ error:
=20
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_tx_fixup);
=20
 /* verify NTB header and return offset of first NDP, or negative error=
 */
 int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *s=
kb_in)
@@ -943,7 +944,7 @@ error:
 }
 EXPORT_SYMBOL_GPL(cdc_ncm_rx_verify_ndp16);
=20
-static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in=
)
+int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
 {
 	struct sk_buff *skb;
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
@@ -1019,6 +1020,7 @@ err_ndp:
 error:
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_rx_fixup);
=20
 static void
 cdc_ncm_speed_change(struct usbnet *dev,
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 2300f74..c3fa807 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -125,5 +125,8 @@ void cdc_ncm_unbind(struct usbnet *dev, struct usb_=
interface *intf);
 struct sk_buff *cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_bu=
ff *skb, __le32 sign);
 int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *s=
kb_in);
 int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffset);
+struct sk_buff *
+cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)=
;
+int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in);
=20
 #endif /* __LINUX_USB_CDC_NCM_H */
--=20
1.7.10.4
