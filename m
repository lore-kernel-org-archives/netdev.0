From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2] bgmac: allow bigger et_swtype nvram variable
Date: Sun, 15 Sep 2013 22:49:08 +0200
Message-ID: <1379278148-6966-1-git-send-email-zajec5@gmail.com>
References: <1379276748-13687-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:54801 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158Ab3IOUtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 16:49:23 -0400
Received: by mail-ee0-f49.google.com with SMTP id d41so1611842eek.22
        for <netdev@vger.kernel.org>; Sun, 15 Sep 2013 13:49:22 -0700 (PDT)
In-Reply-To: <1379276748-13687-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hauke Mehrtens <hauke@hauke-m.de>

Without this patch it is impossible to read et_swtype, because the 1
byte space is needed for the terminating null byte. The max expected
value is 0xF, so now it should be possible to read decimal form ("15")
and hex form ("0xF").

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
V2: Add "From: " - sorry Hauke for the earlier mistake
---
 drivers/net/ethernet/broadcom/bgmac.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 1c6bc96..59f3e0c 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -909,9 +909,9 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 		u8 et_swtype =3D 0;
 		u8 sw_type =3D BGMAC_CHIPCTL_1_SW_TYPE_EPHY |
 			     BGMAC_CHIPCTL_1_IF_TYPE_MII;
-		char buf[2];
+		char buf[4];
=20
-		if (bcm47xx_nvram_getenv("et_swtype", buf, 1) > 0) {
+		if (bcm47xx_nvram_getenv("et_swtype", buf, sizeof(buf)) > 0) {
 			if (kstrtou8(buf, 0, &et_swtype))
 				bgmac_err(bgmac, "Failed to parse et_swtype (%s)\n",
 					  buf);
--=20
1.7.10.4
