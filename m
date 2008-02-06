From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?= <Uwe.Kleine-Koenig@digi.com>
Subject: [RESENT PATCH] mdiobus_register: check bus not being NULL before dereferencing it
Date: Wed,  6 Feb 2008 10:39:19 +0100
Message-ID: <1202290759-14096-1-git-send-email-Uwe.Kleine-Koenig@digi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<ukleinek@informatik.uni-freiburg.de>,
	Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail164.messagelabs.com ([216.82.253.131]:7824 "HELO
	mail164.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759501AbYBFJjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:39:25 -0500
In-Reply-To: 1194435115-2596-1-git-send-email-ukleinek@informatik.uni-freiburg.de
References: 1194435115-2596-1-git-send-email-ukleinek@informatik.uni-freiburg.de
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=C3=B6nig <ukleinek@informatik.uni-freiburg.de>

It doesn't make much sense to check for bus being NULL after using
bus->mdio_lock.

Signed-off-by: Uwe Kleine-K=C3=B6nig <Uwe.Kleine-Koenig@digi.com>
Cc: Andy Fleming <afleming@freescale.com>
---
Hello,

I already sent this patch on November 7, 2007, but without any feedback=
=2E

This is rebased to current Linus' master to account for 35b5f6b1.

Best regards
Uwe

 drivers/net/phy/mdio_bus.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 6e9f619..963630c 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -49,13 +49,13 @@ int mdiobus_register(struct mii_bus *bus)
 	int i;
 	int err =3D 0;
=20
-	mutex_init(&bus->mdio_lock);
-
 	if (NULL =3D=3D bus || NULL =3D=3D bus->name ||
 			NULL =3D=3D bus->read ||
 			NULL =3D=3D bus->write)
 		return -EINVAL;
=20
+	mutex_init(&bus->mdio_lock);
+
 	if (bus->reset)
 		bus->reset(bus);
=20
--=20
1.5.3.8

