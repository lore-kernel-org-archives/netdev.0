From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 18/24] net: cdc_ncm: log signatures in hex
Date: Fri,  1 Nov 2013 11:16:55 +0100
Message-ID: <1383301021-16613-19-git-send-email-bjorn@mork.no>
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

These signatures are well known bit patterns, mostly made up
of ascii characters.  Mentally parsing works best if they
are printed in hex.

Cc: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 73faf05..d49e4c5 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -883,8 +883,9 @@ int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx=
, struct sk_buff *skb_in)
 	nth16 =3D (struct usb_cdc_ncm_nth16 *)skb_in->data;
=20
 	if (le32_to_cpu(nth16->dwSignature) !=3D USB_CDC_NCM_NTH16_SIGN) {
-		pr_debug("invalid NTH16 signature <%u>\n",
-					le32_to_cpu(nth16->dwSignature));
+		netif_dbg(dev, rx_err, dev->net,
+			  "invalid NTH16 signature <%#010x>\n",
+			  le32_to_cpu(nth16->dwSignature));
 		goto error;
 	}
=20
@@ -972,8 +973,9 @@ next_ndp:
 	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)(skb_in->data + ndpoffset);
=20
 	if (le32_to_cpu(ndp16->dwSignature) !=3D USB_CDC_NCM_NDP16_NOCRC_SIGN=
) {
-		pr_debug("invalid DPT16 signature <%u>\n",
-			 le32_to_cpu(ndp16->dwSignature));
+		netif_dbg(dev, rx_err, dev->net,
+			  "invalid DPT16 signature <%#010x>\n",
+			  le32_to_cpu(ndp16->dwSignature));
 		goto err_ndp;
 	}
 	dpe16 =3D ndp16->dpe16;
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
