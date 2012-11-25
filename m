From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: qmi_wwan: add Huawei E173
Date: Sun, 25 Nov 2012 17:03:59 +0100
Message-ID: <1353859439-18260-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer@t-online.de>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57024 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753098Ab2KYQEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2012 11:04:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Huawei E173 is a QMI/wwan device which normally appear
as 12d1:1436 in Linux. The descriptors displayed in that
mode will be picked up by cdc_ether.  But the modem has
another mode with a different device ID and a slightly
different set of descriptors. This is the mode used by
Windows like this:

3Modem:      USB\VID_12D1&PID_140C&MI_00\6&3A1D2012&0&0000
Networkcard: USB\VID_12D1&PID_140C&MI_01\6&3A1D2012&0&0001
Appli.Inter: USB\VID_12D1&PID_140C&MI_02\6&3A1D2012&0&0002
PC UI Inter: USB\VID_12D1&PID_140C&MI_03\6&3A1D2012&0&0003

Reported-by: Thomas Sch=C3=A4fer <tschaefer@t-online.de>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 3b566fa..1ea91f4 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -385,6 +385,7 @@ static const struct usb_device_id products[] =3D {
 	},
=20
 	/* 3. Combined interface devices matching on interface number */
+	{QMI_FIXED_INTF(0x12d1, 0x140c, 1)},	/* Huawei E173 */
 	{QMI_FIXED_INTF(0x19d2, 0x0002, 1)},
 	{QMI_FIXED_INTF(0x19d2, 0x0012, 1)},
 	{QMI_FIXED_INTF(0x19d2, 0x0017, 3)},
--=20
1.7.10.4
