From: "Henrik Rydberg" <rydberg@euromail.se>
Subject: =?UTF-8?q?=5BPATCH=5D=20bcma=3A=20don=27t=20fail=20for=20bad=20SPROM=20CRC?=
Date: Mon,  6 Feb 2012 14:26:41 +0100
Message-ID: <1328534801-3477-1-git-send-email-rydberg@euromail.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Henrik Rydberg <rydberg@euromail.se>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b22.telenor.se ([195.54.99.213]:40123 "EHLO
	smtprelay-b22.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755039Ab2BFNZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 08:25:25 -0500
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-b22.telenor.se (Postfix) with ESMTP id 88F6DC030
	for <netdev@vger.kernel.org>; Mon,  6 Feb 2012 14:25:23 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The brcmsmac driver is now checking the bcma SPROM CRCs, leaving some
chipsets unrecognized that were functional prior to the switch. In
particular, the current code bails out on recent Macbooks. This patch
simply ignores the outcome of the CRC check, with the argument that an
unrecognized SPROM should be treated similarly to a non-existing one.

Cc: Arend van Spriel <arend@broadcom.com>
Cc: Franky (Zhenhui) Lin <frankyl@broadcom.com>
Cc: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
Signed-off-by: Henrik Rydberg <rydberg@euromail.se>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
Hi John,

It seems this patch may have gotten lost, at least I have not seen it
on any of the net/wireless parties. Arend, are you ok with the final
wording?

Thanks,
Henrik

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
