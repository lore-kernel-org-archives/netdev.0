From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 24/24] net: cdc_ncm: no not set tx_max higher than the device supports
Date: Fri,  1 Nov 2013 11:17:01 +0100
Message-ID: <1383301021-16613-25-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49974 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755959Ab3KAKR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:26 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are MBIM devices out there reporting

  dwNtbInMaxSize=3D2048 dwNtbOutMaxSize=3D2048

and since the spec require a datagram max size of at least
2048, this means that a full sized datagram will never fit.

Still, sending larger NTBs than the device supports is not
going to help.  We do not have any other options than either
 a) refusing to bindi, or
 b) respect the insanely low value.

Alternative b will at least make these devices work, so go
for it.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4531f38..11c7033 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -159,8 +159,7 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 	}
=20
 	/* verify maximum size of transmitted NTB in bytes */
-	if ((ctx->tx_max < (CDC_NCM_MIN_HDR_SIZE + ctx->max_datagram_size)) |=
|
-	    (ctx->tx_max > CDC_NCM_NTB_MAX_SIZE_TX)) {
+	if (ctx->tx_max > CDC_NCM_NTB_MAX_SIZE_TX) {
 		dev_dbg(&dev->intf->dev, "Using default maximum transmit length=3D%d=
\n",
 			CDC_NCM_NTB_MAX_SIZE_TX);
 		ctx->tx_max =3D CDC_NCM_NTB_MAX_SIZE_TX;
--=20
1.7.10.4
