From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 09/24] net: cdc_ncm: fix SET_MAX_DATAGRAM_SIZE
Date: Fri,  1 Nov 2013 11:16:46 +0100
Message-ID: <1383301021-16613-10-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49963 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754813Ab3KAKRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:22 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to inform the device about the *new* value, not the
old one.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4de3a542..b8de8dd 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -280,6 +280,7 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 			/* if value changed, update device */
 			if (ctx->max_datagram_size !=3D
 					le16_to_cpu(max_datagram_size)) {
+				max_datagram_size =3D cpu_to_le16(ctx->max_datagram_size);
 				err =3D usbnet_write_cmd(dev,
 						USB_CDC_SET_MAX_DATAGRAM_SIZE,
 						USB_TYPE_CLASS | USB_DIR_OUT
--=20
1.7.10.4
