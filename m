From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next] net: qmi_wwan: ignore bogus CDC Union descriptors
Date: Thu, 17 Dec 2015 12:44:04 +0100
Message-ID: <1450352644-12445-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kanerva Topi <Topi.Kanerva@cinia.fi>, linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43602 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278AbbLQLoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 06:44:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CDC descriptors found on these vendor specific functions should
not be considered authoritative.  They seem to be ignored by drivers
for other systems, and the quality is therefore low.

One device (1e0e:9001) has been reported to have such a bogus union
descriptor on the QMI function, making it fail probing even if the
device id was dynamically added.  The report was not complete enough
to allow adding a device entry for this modem. But this should at
least fix the dynamic id probing problem.

Reported-by: Kanerva Topi <Topi.Kanerva@cinia.fi>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 6f3bf75147e2..ad1f7dfac590 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -374,7 +374,10 @@ static int qmi_wwan_bind(struct usbnet *dev, struc=
t usb_interface *intf)
 				"bogus CDC Union: master=3D%u, slave=3D%u\n",
 				cdc_union->bMasterInterface0,
 				cdc_union->bSlaveInterface0);
-			goto err;
+
+			/* ignore and continue... */
+			cdc_union =3D NULL;
+			info->data =3D intf;
 		}
 	}
=20
--=20
2.1.4
