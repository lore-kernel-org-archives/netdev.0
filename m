From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH 2/2] smsc911x: Remove dev==NULL check.
Date: Wed, 19 Aug 2015 11:46:43 -0500
Message-ID: <1440002803-5113-3-git-send-email-jeremy.linton@arm.com>
References: <1440002803-5113-1-git-send-email-jeremy.linton@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Cc: gregkh@linuxfoundation.org, steve.glendinning@shawell.net,
	linux@roeck-us.net, jeremy.linton@arm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([207.82.80.143]:65294 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751576AbbHSQrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:47:33 -0400
In-Reply-To: <1440002803-5113-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dev=3D=3DNULL check in smsc911x_probe_config is useless
and isn't providing any additional protection. If a fwnode
doesn't exist then an appropriate error should be returned
by device_get_phy_mode() covering the original case
of a missing of/fwnode.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/sm=
sc/smsc911x.c
index 34f9768..6eef325 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2370,9 +2370,6 @@ static int smsc911x_probe_config(struct smsc911x_plat=
form_config *config,
 =09int phy_interface;
 =09u32 width =3D 0;
=20
-=09if (!dev)
-=09=09return -ENODEV;
-
 =09phy_interface =3D device_get_phy_mode(dev);
 =09if (phy_interface < 0)
 =09=09return phy_interface;
--=20
2.4.3
