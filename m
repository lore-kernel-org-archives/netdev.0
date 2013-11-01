From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 22/24] net: cdc_ncm: return proper error if setup fails
Date: Fri,  1 Nov 2013 11:16:59 +0100
Message-ID: <1383301021-16613-23-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49975 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755925Ab3KAKRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:23 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most setup errors are ignored to ensure maximum firmware
compatibilty.  But GET_NTB_PARAMETERS and the functional
descriptors are required.  Use proper error codes and
log level if these fail.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 62dcb2e..f168bc8 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -86,8 +86,8 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 			      0, iface_no, &ncm_parm,
 			      sizeof(ncm_parm));
 	if (err < 0) {
-		dev_dbg(&dev->intf->dev, "failed GET_NTB_PARAMETERS\n");
-		return 1;
+		dev_err(&dev->intf->dev, "failed GET_NTB_PARAMETERS\n");
+		return err; /* GET_NTB_PARAMETERS is required */
 	}
=20
 	/* read correct set of parameters according to device mode */
--=20
1.7.10.4
