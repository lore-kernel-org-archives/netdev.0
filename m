From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net 2/3] net: cdc_mbim: send ZLP after max sized NTBs
Date: Mon, 21 Jan 2013 16:50:39 +0100
Message-ID: <1358783440-11459-3-git-send-email-bjorn@mork.no>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>,
	Oliver Neukum <oneukum@suse.de>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:39569 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752499Ab3AUPvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 10:51:42 -0500
In-Reply-To: <1358783440-11459-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We normally avoid sending ZLPs by padding NTBs with a zero byte
if the NTB is shorter than dwNtbOutMaxSize, resulting in a short
USB packet instead of a ZLP.  But in the case where the NTB length
is exactly dwNtbOutMaxSize and this is an exact multiplum of
wMaxPacketSize, then we must send a ZLP.

This fixes an issue seen on a Sierra Wireless MC7710 device
where the transmission would fail whenever we ended up padding
the NTBs to max size.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_mbim.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 42f51c7..3a5673a 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -366,7 +366,7 @@ err:
=20
 static const struct driver_info cdc_mbim_info =3D {
 	.description =3D "CDC MBIM",
-	.flags =3D FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN,
+	.flags =3D FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN | FLAG_SEND=
_ZLP,
 	.bind =3D cdc_mbim_bind,
 	.unbind =3D cdc_mbim_unbind,
 	.manage_power =3D cdc_mbim_manage_power,
--=20
1.7.10.4
