From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH] macb: don't use platform_set_drvdata() on a net_device
Date: Mon, 28 Feb 2011 14:05:25 +0000
Message-ID: <1298901925-16525-1-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamie Iles <jamie@jamieiles.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65385 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754243Ab1B1OF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 09:05:28 -0500
Received: by fxm17 with SMTP id 17so3749211fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 06:05:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 71d6429 (Driver core: convert platform_{get,set}_drvdata to
static inline functions) now triggers a warning in the macb network
driver:

  CC      drivers/net/macb.o
drivers/net/macb.c: In function =E2=80=98macb_mii_init=E2=80=99:
drivers/net/macb.c:263: warning: passing argument 1 of =E2=80=98platfor=
m_set_drvdata=E2=80=99 from incompatible pointer type
include/linux/platform_device.h:138: note: expected =E2=80=98struct pla=
tform_device *=E2=80=99 but argument is of type =E2=80=98struct net_dev=
ice *=E2=80=99

Use dev_set_drvdata() on the device embedded in the net_device instead.

Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/macb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index f69e73e..79ccb54 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -260,7 +260,7 @@ static int macb_mii_init(struct macb *bp)
 	for (i =3D 0; i < PHY_MAX_ADDR; i++)
 		bp->mii_bus->irq[i] =3D PHY_POLL;
=20
-	platform_set_drvdata(bp->dev, bp->mii_bus);
+	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
=20
 	if (mdiobus_register(bp->mii_bus))
 		goto err_out_free_mdio_irq;
--=20
1.7.4

