From: "Henrik Rydberg" <rydberg@euromail.se>
Subject: Re: [PATCH] bcma: don't fail for bad SPROM CRC
Date: Mon, 6 Feb 2012 14:48:57 +0100
Message-ID: <20120206134857.GA3636@polaris.bitmath.org>
References: <1328534801-3477-1-git-send-email-rydberg@euromail.se>
 <4F2FD6D0.8070508@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b12.telenor.se ([62.127.194.21]:54606 "EHLO
	smtprelay-b12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420Ab2BFNro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 08:47:44 -0500
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-b12.telenor.se (Postfix) with ESMTP id 1D2F7C797
	for <netdev@vger.kernel.org>; Mon,  6 Feb 2012 14:47:42 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <4F2FD6D0.8070508@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 06, 2012 at 02:34:08PM +0100, Arend van Spriel wrote:
> On 02/06/2012 02:26 PM, Henrik Rydberg wrote:
> > The brcmsmac driver is now checking the bcma SPROM CRCs, leaving so=
me
> > chipsets unrecognized that were functional prior to the switch. In
> > particular, the current code bails out on recent Macbooks. This pat=
ch
> > simply ignores the outcome of the CRC check, with the argument that=
 an
> > unrecognized SPROM should be treated similarly to a non-existing on=
e.
>=20
> Suggestion:
>=20
> The brcmsmac driver is now registered as a bcma device driver. Some
> chipsets fail on SPROM CRC check in the bcma bus driver. This leaves =
the
> chipset unrecognized and the bcma bus is not registered so that brcms=
mac
> is not probed. In particular, the current code .......

All fine with me. To avoid confusion, here is the patch again, with
the above inserted.

Thanks,
Henrik

---

=46rom 57a4fbd1767b3c2e7c32d288b713e1b06e597bd6 Mon Sep 17 00:00:00 200=
1
=46rom: Henrik Rydberg <rydberg@euromail.se>
Date: Tue, 31 Jan 2012 14:22:15 -0500
Subject: [PATCH] bcma: don't fail for bad SPROM CRC
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

The brcmsmac driver is now registered as a bcma device driver. Some
chipsets fail on SPROM CRC check in the bcma bus driver. This leaves
the chipset unrecognized and the bcma bus is not registered so that
brcmsmac is not probed. In particular, the current code bails out on
recent Macbooks. This patch simply ignores the outcome of the CRC
check, with the argument that an unrecognized SPROM should be treated
similarly to a non-existing one.

Cc: Arend van Spriel <arend@broadcom.com>
Cc: Franky (Zhenhui) Lin <frankyl@broadcom.com>
Cc: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
Signed-off-by: Henrik Rydberg <rydberg@euromail.se>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/bcma/main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index febbc0a..ec31f7d 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -169,10 +169,8 @@ int bcma_bus_register(struct bcma_bus *bus)
 	err =3D bcma_sprom_get(bus);
 	if (err =3D=3D -ENOENT) {
 		pr_err("No SPROM available\n");
-	} else if (err) {
+	} else if (err)
 		pr_err("Failed to get SPROM: %d\n", err);
-		return -ENOENT;
-	}
=20
 	/* Register found cores */
 	bcma_register_cores(bus);
--=20
1.7.9
