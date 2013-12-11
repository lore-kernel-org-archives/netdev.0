From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH net-next] bgmac: reset cached MAC state during chip reset
Date: Wed, 11 Dec 2013 07:44:14 +0100
Message-ID: <1386744254-32408-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:35623 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3LKGoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 01:44:24 -0500
Received: by mail-ea0-f175.google.com with SMTP id z10so2659213ead.6
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 22:44:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this bgmac_adjust_link didn't know it should re-initialize MAC
state. This led to the MAC not working after if down & up routine.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 055204e..5b5ac71 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -951,6 +951,8 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 			     BGMAC_CMDCFG_CFE |
 			     BGMAC_CMDCFG_SR,
 			     false);
+	bgmac->mac_speed =3D SPEED_UNKNOWN;
+	bgmac->mac_duplex =3D DUPLEX_UNKNOWN;
=20
 	bgmac_clear_mib(bgmac);
 	if (core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT)
--=20
1.7.10.4
