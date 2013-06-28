From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH 1/3] net: qmi_wwan: fixup Sierra Wireless MC8305 entry
Date: Fri, 28 Jun 2013 17:17:49 +0200
Message-ID: <1372432671-17283-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:42814 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751393Ab3F1PRy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 11:17:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MC8305 module got an additional entry added based solely on
information from a Windows driver *.inf file. We now have the
actual descriptor layout from one of these modules, and it
consists of two alternate configurations where cfg #1 is a
normal Gobi 2k layout and cfg #2 is MBIM only, using interface
numbers 5 and 6 for MBIM control and data. The extra Windows
driver entry for interface number 5 was most likely a bug.

Deleting the bogus entry to avoid unnecessary qmi_wwan probe
failures when using the MBIM configuration.

Reported-by: Lana Black <sickmind@lavabit.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index d095d0d..1d1021c 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -625,7 +625,6 @@ static const struct usb_device_id products[] =3D {
 	{QMI_GOBI_DEVICE(0x1199, 0x9009)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
 	{QMI_GOBI_DEVICE(0x1199, 0x900a)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
 	{QMI_GOBI_DEVICE(0x1199, 0x9011)},	/* Sierra Wireless Gobi 2000 Modem=
 device (MC8305) */
-	{QMI_FIXED_INTF(0x1199, 0x9011, 5)},	/* alternate interface number!? =
*/
 	{QMI_GOBI_DEVICE(0x16d8, 0x8002)},	/* CMDTech Gobi 2000 Modem device =
(VU922) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x9205)},	/* Gobi 2000 Modem device */
 	{QMI_GOBI_DEVICE(0x1199, 0x9013)},	/* Sierra Wireless Gobi 3000 Modem=
 device (MC8355) */
--=20
1.7.10.4
