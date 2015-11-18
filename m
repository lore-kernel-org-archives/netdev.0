From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable] net: qmi_wwan: add XS Stick W100-2 from 4G Systems
Date: Wed, 18 Nov 2015 21:13:07 +0100
Message-ID: <1447877587-19986-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer@t-online.de>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:42085 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754512AbbKRUNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 15:13:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas reports
"
4gsystems sells two total different LTE-surfsticks under the same name.
=2E.
The newer version of XS Stick W100 is from "omega"
=2E.
Under windows the driver switches to the same ID, and uses MI03\6 for
network and MI01\6 for modem.
=2E.
echo "1c9e 9b01" > /sys/bus/usb/drivers/qmi_wwan/new_id
echo "1c9e 9b01" > /sys/bus/usb-serial/drivers/option1/new_id

T:  Bus=3D01 Lev=3D01 Prnt=3D01 Port=3D03 Cnt=3D01 Dev#=3D  4 Spd=3D480=
 MxCh=3D 0
D:  Ver=3D 2.00 Cls=3D00(>ifc ) Sub=3D00 Prot=3D00 MxPS=3D64 #Cfgs=3D  =
1
P:  Vendor=3D1c9e ProdID=3D9b01 Rev=3D02.32
S:  Manufacturer=3DUSB Modem
S:  Product=3DUSB Modem
S:  SerialNumber=3D
C:  #Ifs=3D 5 Cfg#=3D 1 Atr=3D80 MxPwr=3D500mA
I:  If#=3D 0 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Doption
I:  If#=3D 1 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Doption
I:  If#=3D 2 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Doption
I:  If#=3D 3 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Dqmi_wwan
I:  If#=3D 4 Alt=3D 0 #EPs=3D 2 Cls=3D08(stor.) Sub=3D06 Prot=3D50 Driv=
er=3Dusb-storage

Now all important things are there:

wwp0s29f7u2i3 (net), ttyUSB2 (at), cdc-wdm0 (qmi), ttyUSB1 (at)

There is also ttyUSB0, but it is not usable, at least not for at.

The device works well with qmi and ModemManager-NetworkManager.
"

Reported-by: Thomas Sch=C3=A4fer <tschaefer@t-online.de>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 34799eaace41..9a5be8b85186 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -725,6 +725,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x2357, 0x9000, 4)},	/* TP-LINK MA260 */
 	{QMI_FIXED_INTF(0x1bc7, 0x1200, 5)},	/* Telit LE920 */
 	{QMI_FIXED_INTF(0x1bc7, 0x1201, 2)},	/* Telit LE920 */
+	{QMI_FIXED_INTF(0x1c9e, 0x9b01, 3)},	/* XS Stick W100-2 from 4G Syste=
ms */
 	{QMI_FIXED_INTF(0x0b3c, 0xc000, 4)},	/* Olivetti Olicard 100 */
 	{QMI_FIXED_INTF(0x0b3c, 0xc001, 4)},	/* Olivetti Olicard 120 */
 	{QMI_FIXED_INTF(0x0b3c, 0xc002, 4)},	/* Olivetti Olicard 140 */
--=20
2.1.4
