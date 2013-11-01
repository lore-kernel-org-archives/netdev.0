From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 19/24] net: cdc_ncm: endian convert constants instead of variables
Date: Fri,  1 Nov 2013 11:16:56 +0100
Message-ID: <1383301021-16613-20-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Converting the constants used in these comparisons at build
time instead of converting the variables for every received
frame at run time.

Cc: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index d49e4c5..83e6d5b 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -882,7 +882,7 @@ int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx=
, struct sk_buff *skb_in)
=20
 	nth16 =3D (struct usb_cdc_ncm_nth16 *)skb_in->data;
=20
-	if (le32_to_cpu(nth16->dwSignature) !=3D USB_CDC_NCM_NTH16_SIGN) {
+	if (nth16->dwSignature !=3D cpu_to_le32(USB_CDC_NCM_NTH16_SIGN)) {
 		netif_dbg(dev, rx_err, dev->net,
 			  "invalid NTH16 signature <%#010x>\n",
 			  le32_to_cpu(nth16->dwSignature));
@@ -972,7 +972,7 @@ next_ndp:
=20
 	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)(skb_in->data + ndpoffset);
=20
-	if (le32_to_cpu(ndp16->dwSignature) !=3D USB_CDC_NCM_NDP16_NOCRC_SIGN=
) {
+	if (ndp16->dwSignature !=3D cpu_to_le32(USB_CDC_NCM_NDP16_NOCRC_SIGN)=
) {
 		netif_dbg(dev, rx_err, dev->net,
 			  "invalid DPT16 signature <%#010x>\n",
 			  le32_to_cpu(ndp16->dwSignature));
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
